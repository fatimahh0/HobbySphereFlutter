// Flutter 3.35.x
// Build a proper WebSocket URL from an HTTP base with a flexible path.

String wsUrlFromHttp(
  String httpBase, {
  String path = '/ws', // most Spring/SockJS setups mount here
}) {
  final u = Uri.parse(httpBase);
  final scheme = (u.scheme == 'https') ? 'wss' : 'ws';
  final host = u.host;
  final port = u.hasPort ? ':${u.port}' : '';
  final p = path.startsWith('/') ? path : '/$path';
  return '$scheme://$host$port$p';
}
