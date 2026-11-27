/// What a cloud session left behind when it ended: whether there was one,
/// and the last session total that was already counted.
typedef MeteredSessionEnd = ({bool wasCloud, int? lastCounted});

/// Counts a cloud session's traffic toward today's quota.
///
/// The engine reports running session totals. The meter turns them into
/// new bytes and saves the last counted total, so usage from a session that
/// ran on while the app was closed can still be counted later. When the
/// server meters traffic itself, an implementation can count nothing and
/// the connection code stays the same.
abstract class CloudSessionMeter {
  const CloudSessionMeter();

  bool get isTracking;

  /// Starts a new session at [sessionTotal] (nothing before it counts).
  void start(int sessionTotal);

  /// The app restarted while the tunnel kept running: continue from the
  /// saved total, so the next update counts everything used meanwhile.
  /// With no saved total the next update is only a starting point.
  void resume();

  /// New bytes to count for the engine's [sessionTotal].
  int record(int sessionTotal);

  /// Stops counting and forgets the session. Does nothing if not tracking.
  void stop();

  /// Ends the session, live or left over from a killed app, and returns
  /// what is needed to settle it.
  MeteredSessionEnd end();

  /// Marks a cloud session that already stopped with [sessionTotal], so
  /// [end] treats it as one.
  Future<void> markEnded(int sessionTotal);

  /// Forgets any session, including a leftover marker.
  Future<void> clear();
}
