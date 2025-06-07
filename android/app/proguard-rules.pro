# Keep ZEGO classes
-keep class **.zego.** { *; }
-keep class **.**.zego_zpns.** { *; }

# Razorpay SDK
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Ignore missing annotation classes — DO NOT keep them
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# If they are referenced in code, suppress missing class errors
-ignorewarnings

# If needed, keep all annotations
-keepattributes *Annotation*
