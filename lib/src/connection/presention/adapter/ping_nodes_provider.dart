import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/src/connection/domain/usecase/ping_nodes.dart';

final pingNodesProvider = Provider<PingNodes>((ref) => sl<PingNodes>());
