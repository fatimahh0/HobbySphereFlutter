// Flutter 3.35.x
// Build a proper WebSocket URL from an HTTP base + path.

String wsUrlFromHttp(
  String httpBase, {
  String path = '/ws', // default path
}) {
  final u = Uri.parse(httpBase); // parse base
  final scheme = (u.scheme == 'https') ? 'wss' : 'ws'; // ws or wss
  final host = u.host; // host
  final port = u.hasPort ? ':${u.port}' : ''; // optional port
  final p = path.startsWith('/') ? path : '/$path'; // ensure leading /
  return '$scheme://$host$port$p'; // full ws url
}
