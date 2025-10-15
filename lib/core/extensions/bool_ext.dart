extension BoolExt on bool {
  String get stringValue {
    return switch (this) {
      true => 'true',
      _ => 'false',
    };
  }
}
