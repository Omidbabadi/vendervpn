import 'package:equatable/equatable.dart';

class IpInfo extends Equatable {
  const IpInfo({
    required this.ip,
    required this.countryCode,
    required this.countryName,
    required this.city,
    this.isTunnel = false,
  });

  final String ip;
  final String countryCode;
  final String countryName;
  final String city;
  final bool isTunnel;

  String get displayLocation {
    if (city.isNotEmpty && countryName.isNotEmpty && city != countryName) {
      return '$city, $countryName';
    }
    if (countryName.isNotEmpty) return countryName;
    return countryCode;
  }

  @override
  List<Object?> get props => [ip, countryCode, countryName, city, isTunnel];
}
