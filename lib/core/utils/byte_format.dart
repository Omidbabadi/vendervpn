/// A byte count in binary units, e.g. `1.5 MB` or `2.00 GB`.
String formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const kb = 1024.0;
  const mb = kb * 1024.0;
  const gb = mb * 1024.0;
  const tb = gb * 1024.0;

  if (bytes >= tb) {
    return '${(bytes / tb).toStringAsFixed(2)} TB';
  } else if (bytes >= gb) {
    return '${(bytes / gb).toStringAsFixed(2)} GB';
  } else if (bytes >= mb) {
    return '${(bytes / mb).toStringAsFixed(1)} MB';
  } else if (bytes >= kb) {
    return '${(bytes / kb).toStringAsFixed(1)} KB';
  }
  return '$bytes B';
}
