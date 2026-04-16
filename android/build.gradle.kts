allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.add("-Xlint:none")
        options.compilerArgs.add("-nowarn")
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
