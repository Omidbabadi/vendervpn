{pkgs}: {
  channel = "stable-24.05";
  packages = [
    pkgs.jdk17
    pkgs.unzip
    pkgs.nano
    pkgs.sudo
  ];
  idx.extensions = [
    
  
 "Dart-Code.dart-code"
 "Dart-Code.flutter"
 "Google.arb-editor"];
  idx.previews = {
      enable = true;
    previews = {
      android = {
        command = [
          "flutter"
          "run"
          "--machine"
          "-d"
          "android"
          "-d"
          "localhost:5555"
        ];
        manager = "flutter";
      };
    };
  };
}