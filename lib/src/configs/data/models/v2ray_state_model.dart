import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/common/entities/v2ray_state.dart';

class V2RayStateModel extends V2RayState {
  const V2RayStateModel({
    super.download,
    super.downloadSpeed,
    super.duration,
    super.state,
    super.upload,
    super.uploadSpeed,
  });

  factory V2RayStateModel.fromV2rayStatus(V2RayStatus status) {
    return V2RayStateModel(
      download: status.download,
      downloadSpeed: status.downloadSpeed,
      duration: status.duration,
      state: status.state,
      upload: status.upload,
      uploadSpeed: status.uploadSpeed,
    );
  }
}
