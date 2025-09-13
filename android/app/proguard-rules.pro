# ========================
# Razorpay classes
# ========================
-keep class com.razorpay.** { *; }

# ========================
# Google Pay / Razorpay GPay classes
# ========================
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**

# ========================
# Annotations (prevent removal)
# ========================
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# ========================
# Flutter classes
# ========================
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# ========================
# Firebase / Google Play Services
# ========================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Firebase model fields annotated with @IgnoreExtraProperties
-keepclassmembers class * {
    @com.google.firebase.database.IgnoreExtraProperties <fields>;
}

# General rules to avoid removing annotations
-keepattributes *Annotation*

# ========================
# Miscellaneous fixes
# ========================
# Keep all classes referenced by reflection
-keep class * implements java.io.Serializable
-keepclassmembers class * {
    java.lang.Class class$(java.lang.String);
}
