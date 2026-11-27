/// Where a node comes from.
///
/// Cloud nodes are managed on the server and go through the quota and ad
/// pipeline. Local nodes are imported by the user and connect directly.
enum NodeSource {
  cloud,
  local;

  /// The `importedFrom` value saved for cloud nodes. Local nodes keep their
  /// own import tag (for example `sub:<name>`).
  static const cloudTag = 'cloud';

  static NodeSource fromImportedFrom(String importedFrom) =>
      importedFrom == cloudTag ? NodeSource.cloud : NodeSource.local;
}
