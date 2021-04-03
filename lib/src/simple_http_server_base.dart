import 'dart:convert';
import 'dart:io';

abstract class SimpleHttpServer {
  static const GET = 'GET';
  static const POST = 'POST';
  static const PUT = 'PUT';
  static const DELETE = 'DELETE';
  static const DEFAULT = '*';

  late HttpServer httpServer;
  InternetAddress internetAddress = InternetAddress.anyIPv4;
  int port = 8080;
  String _baseDir = '/';

  Map<String, Map<String, Function(HttpRequest)>> handlersMap = {
    DEFAULT: <String, Function(HttpRequest)>{},
    GET: <String, Function(HttpRequest)>{},
    POST: <String, Function(HttpRequest)>{},
    PUT: <String, Function(HttpRequest)>{},
    DELETE: <String, Function(HttpRequest)>{},
  };
  SimpleHttpServer({int? port, InternetAddress? internetAddress}) {
    this.port = port ?? this.port;
    this.internetAddress = internetAddress ?? this.internetAddress;
    _defaultHandlers();
    addHanderls();
  }

  void start() async {
    try {
      httpServer = await HttpServer.bind(internetAddress, port);
      print('Server started at port $port');
      await for (HttpRequest request in httpServer) {
        await _processRequest(request);
        await request.response.close();
      }
    } catch (e) {
      print('error $e');
      exit(-1);
    }
  }

  Future<void> stop() async {
    try {
      await httpServer.close();
      print('Server stopped');
    } catch (e) {
      print('Error stopping $e');
    }
  }

  Future<void> _processRequest(HttpRequest request) async {
    var type = request.method;
    var route = request.uri.path;
    try {
      await execute(type, route, request);
    } catch (e) {
      print('Error calling processResquest $e');
    }
  }

  void add(String type, String route, Function(HttpRequest) function) {
    switch (type) {
      case GET:
        handlersMap[GET]![route] = function;
        break;
      case POST:
        handlersMap[POST]![route] = function;
        break;
      case PUT:
        handlersMap[PUT]![route] = function;
        break;
      case DELETE:
        handlersMap[DELETE]![route] = function;
        break;
      case DEFAULT:
        handlersMap[DEFAULT]![route] = function;
        break;
      default:
        handlersMap[DEFAULT]![route] = function;
        break;
    }
  }

  Future<void> execute(String type, String route, HttpRequest request) async {
    if (handlersMap.containsKey(type) &&
        handlersMap[type]!.containsKey(route)) {
      await handlersMap[type]![route]!.call(request);
    } else {
      await handlersMap['*']!['*']!.call(request);
    }
  }

  Future<String> readFile(String path) async {
    try {
      var file = File(path).readAsStringSync(encoding: utf8);
      return file;
    } catch (e) {
      print('Error reading file $path, $e');
    }
    return '';
  }

  Future<void> loadStaticFilesFromDirectory(String dir) async {
    _baseDir = dir;
    var dirLength = dir.length;
    var systemTempDir = Directory.fromUri(Uri.parse(_baseDir));
    var htmlFiles = systemTempDir
        .list(recursive: true, followLinks: false)
        //.where((path) => path.path.endsWith('html'))
        .map((path) => path.path);
    await for (String file in htmlFiles) {
      print('adding ${file.substring(dirLength)}');
      add(GET, '/${file.substring(dirLength)}', (req) async {
        await _readStaticFile(req);
      });
    }
  }

  Future<void> _readStaticFile(HttpRequest request) async {
    var path = '$_baseDir${request.uri.path}';
    var res = await readFile(path);
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(res);
    await request.response.close();
  }

  void addHanderls();

  void _defaultHandlers() {
    var defaultRoutes = <String>['/', ''];
    defaultRoutes.forEach((route) {
      add(GET, route, (request) {
        request.response.write('Hello Word');
      });
    });
    add(DEFAULT, '*', (request) {
      request.response.write('Not Found');
    });
  }
}
