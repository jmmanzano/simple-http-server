import 'dart:convert';
import 'dart:io';

import 'new_server.dart';

void main() async {
  var port = 8582;
  var server = NewServer(port: port, internetAddress: InternetAddress.anyIPv4);
  server.start();
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
    }
  });
  await Future.delayed(Duration(seconds: 1), () {});
  await server.stop();
}
