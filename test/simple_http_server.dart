import 'package:simple_http_server/simple_http_server.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  group('A group of tests', () {
    late SimpleHttpServer simpleServer;
    var port = 8582;
    var salida = '';

    setUp(() async {
      simpleServer = SimpleServer(port: port);
      simpleServer.start();
      var http = HttpClient();
      await Future.delayed(Duration(seconds: 1), () => {});
      await http
          .get('localhost', port, '/')
          .then((request) => request.close())
          .then((response) async {
        if (response.statusCode == 200) {
          final contents = StringBuffer();
          await for (var data in response.transform(utf8.decoder)) {
            contents.write(data);
          }
          print(contents.toString());
          salida = contents.toString();
        }
      });
    });

    test('First Test', () {
      expect(salida, 'Hello Word');
    });
    tearDown(() async {
      await simpleServer.stop();
    });
  });
}

class SimpleServer extends SimpleHttpServer {
  SimpleServer({int? port, InternetAddress? internetAddress})
      : super(port: port, internetAddress: internetAddress);

  @override
  void addHanderls() {
    add(SimpleHttpServer.GET, '/home', (req) => req.response.write('/home'));
  }
}
