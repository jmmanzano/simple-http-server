import 'dart:io';

import 'package:simple_http_server/simple_http_server.dart';

class NewServer extends SimpleHttpServer {
  NewServer({int? port, InternetAddress? internetAddress})
      : super(port: port, internetAddress: internetAddress);

  @override
  void addHanderls() {
    add(SimpleHttpServer.GET, '/home', (req) => req.response.write('/home'));
  }
}
