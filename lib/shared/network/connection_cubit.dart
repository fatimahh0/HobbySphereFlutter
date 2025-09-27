import 'dart:async'; // for StreamSubscription, Timer
import 'dart:io'; // for InternetAddress.lookup to confirm actual internet
import 'package:bloc/bloc.dart'; // base Cubit
import 'package:connectivity_plus/connectivity_plus.dart'; // network status

/// Simple enum to represent connection states.
enum ConnectionStateX { connected, connecting, offline }

/// Cubit holds and emits the current connection state.
class ConnectionCubit extends Cubit<ConnectionStateX> {
  // plugin instance to read connectivity (Wi-Fi/Cell/None)
  final Connectivity _connectivity = Connectivity(); // connectivity_plus

  // subscriptions / timers
  StreamSubscription<List<ConnectivityResult>>? _sub; // stream subscription
  Timer? _pollTimer; // periodic internet verify while connecting
  Timer? _graceTimer; // short delay to avoid "connecting" flicker

  // tunables
  final Duration
  connectingGrace; // how long to wait before showing "connecting"
  final Duration verifyInterval; // polling interval while connecting
  final Duration dnsTimeout; // timeout for DNS lookup

  ConnectionCubit({
    this.connectingGrace = const Duration(milliseconds: 600), // 0.6s grace
    this.verifyInterval = const Duration(seconds: 2), // poll every 2s
    this.dnsTimeout = const Duration(milliseconds: 900), // fast DNS check
  }) : super(ConnectionStateX.connecting) {
    _startMonitoring(); // begin listeners and first check
  }

  void _startMonitoring() {
    // subscribe to connectivity changes (wifi/cellular/none)
    _sub = _connectivity.onConnectivityChanged.listen((results) async {
      // normalize to a single result; plugin returns list on some platforms
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      // handle change with grace/flicker-free logic
      await _handleConnectivityChange(result); // async to allow awaits
    });

    // also do a first check at startup (in case no event fires)
    _kickoffCheck(); // one-shot initial verification
  }

  Future<void> _kickoffCheck() async {
    // read current platform connectivity
    final res = await _connectivity.checkConnectivity(); // current status
    await _handleConnectivityChange(
      res as ConnectivityResult,
    ); // reuse same logic
  }

  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    // cancel any previous timers/polling when state changes
    _cancelGrace(); // stop grace window timer
    _cancelPoll(); // stop periodic verify

    // if no network adapters at all => definitely offline
    if (result == ConnectivityResult.none) {
      emit(ConnectionStateX.offline); // show offline immediately
      return; // exit
    }

    // we have some network (wifi/cellular), confirm real internet quickly
    final ok = await _hasInternet(); // fast DNS resolve with timeout
    if (ok) {
      emit(ConnectionStateX.connected); // connected immediately, no flicker
      return; // done
    }

    // internet not confirmed yet → start a small grace window
    // we delay showing "connecting" to avoid false flash at app start
    _graceTimer = Timer(connectingGrace, () {
      // after grace, if still not connected => show connecting + start polling
      if (state != ConnectionStateX.connected) {
        emit(ConnectionStateX.connecting); // show spinner now
        _verifyInternetLoop(); // begin periodic verification
      }
    });
  }

  void _verifyInternetLoop() {
    // poll every [verifyInterval] until we confirm internet
    _pollTimer = Timer.periodic(verifyInterval, (t) async {
      final ok = await _hasInternet(); // DNS test
      if (ok) {
        emit(ConnectionStateX.connected); // connected → hide banner
        _cancelPoll(); // stop polling
        _cancelGrace(); // ensure grace cleared
      } else {
        // keep "connecting" state if we’re still verifying
        if (state != ConnectionStateX.connecting) {
          emit(ConnectionStateX.connecting); // ensure consistent state
        }
      }
    });
  }

  Future<bool> _hasInternet() async {
    try {
      // quick DNS lookup with timeout to confirm actual internet
      final fut = InternetAddress.lookup('example.com'); // lightweight host
      final result = await fut.timeout(dnsTimeout); // fast timeout
      // if we get non-empty with rawAddress => internet is fine
      return result.isNotEmpty &&
          result.first.rawAddress.isNotEmpty; // true/false
    } catch (_) {
      return false; // lookup failed or timed out => no internet yet
    }
  }

  void retryNow() {
    // called by the "Try again" button to force a re-check
    _cancelPoll(); // reset polling
    _cancelGrace(); // reset grace
    emit(
      ConnectionStateX.connecting,
    ); // show spinner immediately (explicit user action)
    _verifyInternetLoop(); // try again
  }

  void _cancelPoll() {
    _pollTimer?.cancel(); // stop timer
    _pollTimer = null; // clear ref
  }

  void _cancelGrace() {
    _graceTimer?.cancel(); // stop timer
    _graceTimer = null; // clear ref
  }

  @override
  Future<void> close() {
    // cleanup all streams/timers
    _cancelPoll(); // stop polling
    _cancelGrace(); // stop grace
    _sub?.cancel(); // stop connectivity listener
    return super.close(); // call parent
  }
}
