plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://repo.maven.apache.org/maven2") }
        maven { url = uri("https://dl.google.com/dl/android/maven2/") }
    }
    
    // Workaround for location package namespace issue
    afterEvaluate {
        pluginManager.withPlugin("com.android.library") {
            extensions.getByType<com.android.build.gradle.LibraryExtension>().apply {
                if (namespace == null) {
                    namespace = "com.lyokone.location"
                }
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
