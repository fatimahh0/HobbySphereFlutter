// Flutter 3.35.x
// connection_cubit.dart — connectivity + server health
// States:
// - offline: no network
// - connecting: checking internet/server
// - serverDown: internet OK but backend not reachable
// - connected: internet + backend reachable

import 'dart:async'; // Timer
import 'dart:io'; // InternetAddress + HttpClient
import 'package:bloc/bloc.dart'; // Cubit
import 'package:connectivity_plus/connectivity_plus.dart'; // network changes

// enum with serverDown included
enum ConnectionStateX { connected, connecting, offline, serverDown }

class ConnectionCubit extends Cubit<ConnectionStateX> {
  final Connectivity _connectivity = Connectivity(); // plugin
  StreamSubscription<List<ConnectivityResult>>? _sub; // listener
  Timer? _pollTimer; // periodic check timer

  final String serverProbeUrl; // health endpoint to ping

  ConnectionCubit({required this.serverProbeUrl})
    : super(ConnectionStateX.connecting) {
    _startMonitoring(); // start listening
  }

  void _startMonitoring() {
    // listen to connectivity changes
    _sub = _connectivity.onConnectivityChanged.listen((results) async {
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none; // one result

      if (result == ConnectivityResult.none) {
        emit(ConnectionStateX.offline); // no network
        _cancelPoll(); // stop timers
        return; // done
      }

      emit(ConnectionStateX.connecting); // we have network → verify
      _cancelPoll(); // clear old timer
      _verifyLoop(); // start periodic probe
    });

    _initialCheck(); // run once on startup
  }

  Future<void> _initialCheck() async {
    final res = await _connectivity.checkConnectivity(); // current network
    if (res == ConnectivityResult.none) {
      emit(ConnectionStateX.offline); // no network at start
      return; // stop
    }

    emit(ConnectionStateX.connecting); // verify next
    final s = await _verdict(); // compute state
    emit(s); // update
    if (s != ConnectionStateX.connected)
      _verifyLoop(); // keep checking if not ready
  }

  void _verifyLoop() {
    // check every 2 seconds until connected
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final s = await _verdict(); // compute state
      emit(s); // update UI
      if (s == ConnectionStateX.connected) _cancelPoll(); // stop when OK
    });
  }

  Future<ConnectionStateX> _verdict() async {
    final hasNet = await _hasInternet(); // DNS reachability
    if (!hasNet) return ConnectionStateX.offline; // no internet

    final ok = await _pingServer(serverProbeUrl); // backend health
    return ok
        ? ConnectionStateX.connected
        : ConnectionStateX.serverDown; // decide
  }

  Future<bool> _hasInternet() async {
    try {
      // simple DNS query to test internet quickly
      final res = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(milliseconds: 700)); // short timeout
      return res.isNotEmpty && res.first.rawAddress.isNotEmpty; // internet OK
    } catch (_) {
      return false; // DNS failed
    }
  }

  Future<bool> _pingServer(String url) async {
    // tolerant probe:
    // - try HEAD then GET
    // - treat ANY HTTP status < 500 as reachable (200/3xx/401/403/404…)
    final c = HttpClient()
      ..connectionTimeout = const Duration(seconds: 2); // fast fail
    try {
      final uri = Uri.parse(url); // parse URL

      HttpClientRequest req; // request holder
      try {
        req = await c
            .openUrl('HEAD', uri)
            .timeout(const Duration(seconds: 2)); // try HEAD
      } catch (_) {
        req = await c
            .getUrl(uri)
            .timeout(const Duration(seconds: 2)); // fallback GET
      }

      req.headers.set(
        HttpHeaders.acceptHeader,
        'application/json',
      ); // hint JSON

      final resp = await req.close().timeout(
        const Duration(seconds: 2),
      ); // send
      final code = resp.statusCode; // http code
      return code > 0 && code < 500; // reachable if not a 5xx error
    } catch (_) {
      return false; // network or handshake error
    } finally {
      c.close(force: true); // cleanup
    }
  }

  void retryNow() {
    emit(ConnectionStateX.connecting); // show spinner
    _cancelPoll(); // reset timer
    _verifyLoop(); // re-check now
  }

  void _cancelPoll() {
    _pollTimer?.cancel(); // stop timer
    _pollTimer = null; // clear
  }

  @override
  Future<void> close() {
    _cancelPoll(); // cleanup
    _sub?.cancel(); // stop listener
    return super.close(); // parent
  }
}
