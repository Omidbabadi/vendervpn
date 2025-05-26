import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:vendervpn/models/config_model.dart';

part 'subscrption_model.g.dart';

@HiveType(typeId: 2)
class SubscrptionModel {
  @HiveField(0)
  final String subURL;

  @HiveField(1)
  List<ConfigModel>? attachedConfigs;

  @HiveField(2)
  final String id;

  SubscrptionModel({
    String? id,
    List<ConfigModel>? attachedConfigs,
    required this.subURL,
  }) : id = id ?? const Uuid().v4(),
       attachedConfigs = attachedConfigs ?? [];

  SubscrptionModel copyWith({
    String? subURL,
    String? id,
    List<ConfigModel>? attachedConfigs,
  }) {
    return SubscrptionModel(
      subURL: subURL ?? this.subURL,
      id: id ?? this.id,
      attachedConfigs: attachedConfigs ?? this.attachedConfigs,
    );
  }
}
