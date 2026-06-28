# Keep Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# video_player / chewie
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# CachedNetworkImage
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**
