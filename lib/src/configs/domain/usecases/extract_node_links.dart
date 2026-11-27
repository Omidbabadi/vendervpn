import 'package:vendervpn/src/configs/domain/repo/local_nodes_repo.dart';

/// Pulls node links (vless://, ss://, …) out of pasted text, which may be
/// plain lines or a base64 blob. Returns an empty list when none are found.
class ExtractNodeLinks {
  const ExtractNodeLinks(this._repo);
  final LocalNodesRepo _repo;

  List<String> call(String rawPayload) => _repo.extractLinks(rawPayload);
}
