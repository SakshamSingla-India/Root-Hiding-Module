plugins {
    id("com.android.library") version "8.0.0" apply false
}

val moduleId = "enhanced-root-hiding"
val moduleName = "Enhanced Root Hiding"
val moduleVersion = "v1.0.0"
val moduleVersionCode = 1
val moduleAuthor = "Saksham"
val moduleDescription = "Enhanced root hiding module combining Shamiko, TrickyStore, and Zygisk functionality with a web UI"

val zipFileName = "${moduleId}-${moduleVersion}.zip"

tasks.register<Zip>("zipRelease") {
    dependsOn("copyFiles")
    archiveFileName.set(zipFileName)
    destinationDirectory.set(file("$projectDir/module/release"))
    from("$projectDir/module/template")
}

tasks.register<Zip>("zipDebug") {
    dependsOn("copyFiles")
    archiveFileName.set(zipFileName.replace(".zip", "-debug.zip"))
    destinationDirectory.set(file("$projectDir/module/release"))
    from("$projectDir/module/template")
}

tasks.register<Copy>("copyFiles") {
    from("$projectDir/webroot")
    into("$projectDir/module/template/webroot")
}

tasks.register<Exec>("installMagiskDebug") {
    dependsOn("zipDebug")
    commandLine("adb", "push", "$projectDir/module/release/${zipFileName.replace(".zip", "-debug.zip")}", "/data/local/tmp/")
    commandLine("adb", "shell", "su", "-c", "magisk --install-module /data/local/tmp/${zipFileName.replace(".zip", "-debug.zip")}")
}

tasks.register<Exec>("installMagiskRelease") {
    dependsOn("zipRelease")
    commandLine("adb", "push", "$projectDir/module/release/$zipFileName", "/data/local/tmp/")
    commandLine("adb", "shell", "su", "-c", "magisk --install-module /data/local/tmp/$zipFileName")
}

tasks.register<Exec>("installMagiskAndRebootDebug") {
    dependsOn("installMagiskDebug")
    commandLine("adb", "shell", "su", "-c", "reboot")
}

tasks.register<Exec>("installMagiskAndRebootRelease") {
    dependsOn("installMagiskRelease")
    commandLine("adb", "shell", "su", "-c", "reboot")
}

tasks.register<Exec>("installKsuDebug") {
    dependsOn("zipDebug")
    commandLine("adb", "push", "$projectDir/module/release/${zipFileName.replace(".zip", "-debug.zip")}", "/data/local/tmp/")
    commandLine("adb", "shell", "su", "-c", "ksud module install /data/local/tmp/${zipFileName.replace(".zip", "-debug.zip")}")
}

tasks.register<Exec>("installKsuRelease") {
    dependsOn("zipRelease")
    commandLine("adb", "push", "$projectDir/module/release/$zipFileName", "/data/local/tmp/")
    commandLine("adb", "shell", "su", "-c", "ksud module install /data/local/tmp/$zipFileName")
}

tasks.register<Exec>("installKsuAndRebootDebug") {
    dependsOn("installKsuDebug")
    commandLine("adb", "shell", "su", "-c", "reboot")
}

tasks.register<Exec>("installKsuAndRebootRelease") {
    dependsOn("installKsuRelease")
    commandLine("adb", "shell", "su", "-c", "reboot")
}
