abstract class V2RayState {
  final String duration;
  final int uploadSpeed;
  final int downloadSpeed;
  final int upload;
  final int download;
  final String state;

  const V2RayState({
    this.duration = "00:00:00",
    this.uploadSpeed = 0,
    this.downloadSpeed = 0,
    this.upload = 0,
    this.download = 0,
    this.state = "DISCONNECTED",
  });

  const V2RayState.empty()
    : download = 0,
      upload = 0,
      duration = "Test String",
      downloadSpeed = 0,
      uploadSpeed = 0,
      state = "Test String";
}
