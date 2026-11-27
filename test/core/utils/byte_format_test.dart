import 'package:flutter_test/flutter_test.dart';
import 'package:vendervpn/core/utils/byte_format.dart';

void main() {
  const kb = 1024;
  const mb = kb * 1024;
  const gb = mb * 1024;
  const tb = gb * 1024;

  test('zero and negative counts', () {
    expect(formatBytes(0), '0 B');
    expect(formatBytes(-5), '0 B');
  });

  test('unit boundaries', () {
    expect(formatBytes(1023), '1023 B');
    expect(formatBytes(kb), '1.0 KB');
    expect(formatBytes(1536), '1.5 KB');
    expect(formatBytes(mb - 1), '1024.0 KB');
    expect(formatBytes(mb), '1.0 MB');
    expect(formatBytes(gb), '1.00 GB');
    expect(formatBytes(gb * 5 ~/ 2), '2.50 GB');
    expect(formatBytes(tb), '1.00 TB');
  });
}
