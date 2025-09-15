// android/settings.gradle.kts

pluginManagement {
    // Read flutter.sdk from local.properties
    val props = java.util.Properties().apply {
        val f = file("local.properties")
        if (f.exists()) f.inputStream().use { load(it) }
    }
    val flutterSdk = props.getProperty("flutter.sdk")
        ?: error("flutter.sdk not set in local.properties")

    // Ensure Gradle finds the *real* Flutter plugin classes
    includeBuild("$flutterSdk/packages/flutter_tools/gradle")

    // IMPORTANT: include google() here so com.android.application resolves
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Pick one set of versions and keep them here (not in root build.gradle.kts)
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
