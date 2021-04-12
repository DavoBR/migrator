import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

Future<HttpClientResponse> http(
  String method,
  String url, {
  Map<String, dynamic?> params = const {},
  Map<String, String?> headers = const {},
  String? body,
  String? contentType,
  String? username,
  String? password,
  Uint8List? certificate,
  Function(HttpClientRequest)? requestHook,
}) async {
  String? basicAuth;
  SecurityContext? securityCtx;
  HttpClientRequest request;

  try {
    if (username != null && password != null) {
      basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    } else if (certificate != null && password != null) {
      securityCtx = SecurityContext(withTrustedRoots: true);
      securityCtx.useCertificateChainBytes(certificate, password: password);
      securityCtx.usePrivateKeyBytes(certificate, password: password);
    }

    var uri = Uri.parse(url);

    if (params.isNotEmpty) {
      params.removeWhere((key, value) => value == null);
      uri = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        path: uri.path,
        queryParameters: params,
      );
    }

    final http = new HttpClient(context: securityCtx);

    request = await http.openUrl(method, uri);

    if (headers.isNotEmpty) {
      headers.forEach((key, value) {
        if (value != null) {
          request.headers.add(key, value);
        }
      });
    }

    if (basicAuth != null) {
      request.headers.add('Authorization', basicAuth);
    }

    if (body != null && body.isNotEmpty) {
      if (contentType != null && contentType.isNotEmpty) {
        request.headers.add("Content-Type", contentType);
      }

      request.add(utf8.encode(body));
    }

    if (requestHook != null) {
      requestHook(request);
    }

    final response = await request.close();

    return response;
  } on SocketException {
    throw Exception('Revisa la conexión a internet 😑');
  }
}
