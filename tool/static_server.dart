import 'dart:io';

Future<void> main(List<String> args) async {
  final root = args.isNotEmpty ? args.first : 'build/web';
  final port = args.length > 1 ? int.parse(args[1]) : 8080;
  final directory = Directory(root);
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('Serving ${directory.absolute.path} on http://0.0.0.0:$port');

  await for (final request in server) {
    if (request.uri.path == '/api/polymarket/events') {
      await _proxyPolymarketEvents(request);
      continue;
    }

    final rawPath = Uri.decodeComponent(request.uri.path);
    final relativePath = rawPath == '/' ? 'index.html' : rawPath.substring(1);
    final file = File('${directory.path}${Platform.pathSeparator}$relativePath');
    final target = await file.exists() ? file : File('${directory.path}${Platform.pathSeparator}index.html');

    request.response.headers.contentType = _contentType(target.path);
    request.response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
    request.response.headers.set(HttpHeaders.pragmaHeader, 'no-cache');
    request.response.headers.set(HttpHeaders.expiresHeader, '0');
    await target.openRead().pipe(request.response);
  }
}

Future<void> _proxyPolymarketEvents(HttpRequest request) async {
  final upstream = Uri.https('gamma-api.polymarket.com', '/events', request.uri.queryParameters);
  final client = HttpClient();
  try {
    final upstreamRequest = await client.getUrl(upstream);
    upstreamRequest.headers.set(HttpHeaders.acceptHeader, 'application/json');
    upstreamRequest.headers.set(HttpHeaders.userAgentHeader, 'polymarket-ev-desk/0.1');
    final upstreamResponse = await upstreamRequest.close();
    request.response.statusCode = upstreamResponse.statusCode;
    request.response.headers.contentType = ContentType.json;
    request.response.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
    await upstreamResponse.pipe(request.response);
  } catch (error) {
    request.response.statusCode = HttpStatus.badGateway;
    request.response.headers.contentType = ContentType.json;
    request.response.write('{"error":"$error"}');
    await request.response.close();
  } finally {
    client.close(force: true);
  }
}

ContentType _contentType(String path) {
  if (path.endsWith('.html')) return ContentType.html;
  if (path.endsWith('.js')) return ContentType('application', 'javascript');
  if (path.endsWith('.json')) return ContentType.json;
  if (path.endsWith('.png')) return ContentType('image', 'png');
  if (path.endsWith('.wasm')) return ContentType('application', 'wasm');
  if (path.endsWith('.css')) return ContentType('text', 'css');
  return ContentType.binary;
}
