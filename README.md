A wrapper for HttpServer.

## Usage

A simple usage example:

You need create a new class that extends from **SimpleHttpServer**.
This new class must override the _addHanderls_ parent method. Also you can create a new Constructor to specificate the Port and the InternetAdress.

```dart
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
```

After this you can create a new instance of your class and start the server:

```dart
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
      .get('localhost', port, '/home')
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
```

By default port is 8080 and InternetAddress is anyIPv4.

## Features and bugs

Source code at [GitHub repository][repo].

[repo]: https://github.com/jmmanzano/simple-http-server

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/jmmanzano/simple-http-server/issues
