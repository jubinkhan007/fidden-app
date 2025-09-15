// android/build.gradle.kts (root)

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// (Optional) custom build directory mapping you already have:
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// DO NOT put a `plugins { ... }` block here for com.android.application, etc.
// Keep plugin versions in settings.gradle.kts.
