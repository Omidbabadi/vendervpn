class Config {
  final String configjson;

  final String importedFrom;

  final String remark;

  final int port;

  final String address;

  final String uri;

  final String dateAdded;

  final String id;

  final String? country;

  final bool isSelected;

  final String? serverIp;

  final int ping;

  const Config({
    required this.configjson,
    required this.importedFrom,
    required this.remark,
    required this.port,
    required this.address,
    required this.uri,
    required this.dateAdded,
    required this.id,
    required this.isSelected,
    required this.ping,
    this.country,
    this.serverIp,
  });

  const Config.empty()
    : address = 'Test String',
      configjson = 'Test String',
      importedFrom = 'Test String',
      port = 0,
      remark = 'Test String',
      uri = 'Test String',
      dateAdded = 'Test String',
      id = 'Test String',
      isSelected = false,
      country = 'Test String',
      serverIp = 'Test String',
      ping = -1;
}
