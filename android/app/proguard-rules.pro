# Keep ML Kit text recognition classes
-keep class com.google.mlkit.vision.** { *; }
-keep class com.google.android.gms.** { *; }
-keepnames class com.google.mlkit.vision.** { *; }
-keepnames class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.vision.**
-dontwarn com.google.android.gms.**
