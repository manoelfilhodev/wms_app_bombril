# Flutter
# Keep only the generated registrant (loaded reflectively).
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
# Flutter may reference deferred component classes even when Play Feature Delivery is not used.
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Dart
-keepclasseswithmembernames class ** {
    native <methods>;
}

# Retrofit & Dio
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep interface com.google.gson.** { *; }
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }
-keep class io.k8s.** { *; }
-keep interface io.k8s.** { *; }

# Preserve generic signatures
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes SourceFile,LineNumberTable

# SQLite
-keep class androidx.sqlite.** { *; }

# Keep app components
-keep public class com.example.wms_app.** { *; }
