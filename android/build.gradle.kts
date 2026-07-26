allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                compileSdk = 36
            }
        }
        if (plugins.hasPlugin("org.jetbrains.kotlin.android")) {
            extensions.configure<org.jetbrains.kotlin.gradle.dsl.KotlinAndroidExtension> {
                compilerOptions {
                    languageVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_0)
                    apiVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_0)
                }
            }
        }
    }
    val newSubprojectBuildDir: Directory = rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
        .dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
