# Keep AndroidX Room & WorkManager generated database implementations (prevents R8 from stripping WorkDatabase_Impl)
-keep class * extends androidx.room.RoomDatabase { *; }
-keep @androidx.room.Database class * { *; }
-keep class androidx.work.** { *; }
-keep class androidx.startup.** { *; }

# Keep V2Ray / Go mobile native bindings & Serializable VPN config passed via Intent
-keep class libv2ray.** { *; }
-keep class go.** { *; }
-keep class dev.amirzr.flutter_v2ray_client.** { *; }
