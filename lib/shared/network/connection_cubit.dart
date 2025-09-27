import 'dart:async'; // for StreamSubscription, Timer
import 'dart:io'; // for InternetAddress.lookup to confirm actual internet
import 'package:bloc/bloc.dart'; // base Cubit
import 'package:connectivity_plus/connectivity_plus.dart'; // network status

/// Simple enum to represent connection states.
enum ConnectionStateX { connected, connecting, offline }

/// Cubit holds and emits the current connection state.
class ConnectionCubit extends Cubit<ConnectionStateX> {
  // listen to platform connectivity changes
  final Connectivity _connectivity = Connectivity(); // plugin instance
  StreamSubscription<List<ConnectivityResult>>? _sub; // stream subscription
  Timer? _pollTimer; // small timer to re-check internet while connecting

  ConnectionCubit() : super(ConnectionStateX.connecting) {
    // start by checking now (app start)
    _startMonitoring(); // begin listeners and first check
  }

  void _startMonitoring() {
    // subscribe to connectivity changes (wifi/cellular/none)
    _sub = _connectivity.onConnectivityChanged.listen((results) async {
      // normalize to a single result; plugin returns list on some platforms
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;

      // if no network at all => emit offline immediately
      if (result == ConnectivityResult.none) {
        emit(ConnectionStateX.offline); // show offline banner
        _cancelPoll(); // stop any polling timers
        return; // exit here
      }

      // we have some network (wifi/cellular), but we still need real internet
      emit(ConnectionStateX.connecting); // show "Connecting..." spinner
      _cancelPoll(); // clear older polling
      _verifyInternetLoop(); // begin periodic verification
    });

    // also do a first check at startup (in case no event fires)
    _kickoffCheck(); // one-shot initial verification
  }

  Future<void> _kickoffCheck() async {
    // check current platform connectivity
    final res = await _connectivity.checkConnectivity(); // current status
    if (res == ConnectivityResult.none) {
      emit(ConnectionStateX.offline); // offline at startup
      return; // stop here
    }
    // try to resolve a domain to confirm real internet
    emit(ConnectionStateX.connecting); // we are trying to confirm
    final ok = await _hasInternet(); // DNS lookup check
    emit(
      ok ? ConnectionStateX.connected : ConnectionStateX.connecting,
    ); // set state
    if (!ok) _verifyInternetLoop(); // if still not sure, keep polling
  }

  void _verifyInternetLoop() {
    // poll every 2 seconds until we confirm internet
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (t) async {
      final ok = await _hasInternet(); // test internet access
      if (ok) {
        emit(ConnectionStateX.connected); // hide banner
        _cancelPoll(); // stop polling
      } else {
        emit(ConnectionStateX.connecting); // keep spinner on
      }
    });
  }

  Future<bool> _hasInternet() async {
    try {
      // quick DNS lookup to confirm actual internet
      final result = await InternetAddress.lookup('example.com'); // fast host
      // if we get non-empty with rawAddress => internet is fine
      return result.isNotEmpty &&
          result.first.rawAddress.isNotEmpty; // true/false
    } catch (_) {
      return false; // lookup failed => no internet
    }
  }

  void retryNow() {
    // called by the "Try again" button to force a re-check
    emit(ConnectionStateX.connecting); // show spinner immediately
    _cancelPoll(); // reset polling
    _verifyInternetLoop(); // try again
  }

  void _cancelPoll() {
    // helper to stop timer if active
    _pollTimer?.cancel(); // cancel
    _pollTimer = null; // clear
  }

  @override
  Future<void> close() {
    // cleanup all streams/timers
    _cancelPoll(); // stop polling
    _sub?.cancel(); // stop connectivity listener
    return super.close(); // call parent
  }
}
