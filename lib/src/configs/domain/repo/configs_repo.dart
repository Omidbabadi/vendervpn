import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

abstract class ConfigsRepo {
  ResultFuture<List<Config>> getConfigs();
}
