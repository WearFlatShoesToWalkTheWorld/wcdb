# WCDB

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/Tencent/wcdb/pulls)
[![Release Version](https://img.shields.io/badge/release-1.0.5-brightgreen.svg)](https://github.com/Tencent/wcdb/releases)
[![WeChat Approved iOS](https://img.shields.io/badge/Wechat_Approved_iOS-1.0.5-brightgreen.svg)](https://github.com/Tencent/wcdb/blob/master/README.md#wcdb-for-iosmacos)
[![WeChat Approved Android](https://img.shields.io/badge/Wechat_Approved_Android-1.0.5-brightgreen.svg)](https://github.com/Tencent/wcdb/blob/master/README.md#wcdb-for-android)
[![Platform](https://img.shields.io/badge/Platform-%20iOS%20%7C%20macOS%20%7C%20Android-brightgreen.svg)](https://github.com/Tencent/wcdb/wiki)

中文版本请参看[这里][wcdb-wiki]

WCDB is an **efficient**, **complete**, **easy-to-use** mobile database framework used in the WeChat application. It's currently available on iOS, macOS and Android.

# WCDB for iOS/macOS

## Features

* **Easy-to-use**. Through WCDB, you can get objects from database in one line code. 

  * **WINQ** (WCDB language integrated query): WINQ is a native data querying capability which frees developers from writing glue code to concatenate SQL query strings.

  * **ORM** (Object Relational Mapping): WCDB provides a flexible, easy-to-use ORM for creating tables, indices and constraints, as well as CRUD through ObjC objects.

    ```objective-c
    [database getObjectsOfClass:WCTSampleConvenient.class
                      fromTable:tableName
                          where:WCTSampleConvenient.intValue>=10
                          limit:20];
    ```

* **Efficient**. Through the framework layer and sqlcipher source optimization, WCDB have more efficient performance.

  * **Multi-threaded concurrency**: WCDB supports concurrent read-read and read-write access via connection pooling.
  * **Batch Write Performance Test**.
    ![](https://raw.githubusercontent.com/wiki/Tencent/wcdb/assets/benchmark/baseline_batch_write.png)
    For more benchmark data, please refer to [our benchmark][Benchmark-iOS].

* **Complete**.

  * **Encryption Support**: WCDB supports database encryption via [SQLCipher][sqlcipher].
  * **Corruption recovery**: WCDB provides a built-in repair kit for database corruption recovery.
  * **Anti-injection**: WCDB provides a built-in protection from SQL injection.

## Getting Started

### Prerequisites

* Apps using WCDB can target: iOS 7 or later, macOS 10.9 or later.
* Xcode 8.0 or later required.
* Objective-C++ required.

### Installation

* **Via Cocoapods:**
  1. Install [CocoaPods.](https://guides.cocoapods.org/using/getting-started.html)
  2. Run `pod repo update` to make CocoaPods aware of the latest available WCDB versions.
  3. In your Podfile, add `pod 'WCDB'` to your app target.
  4. From the command line, run `pod install`.
  5. Use the `.xcworkspace` file generated by CocoaPods to work on your project!
  6. Add `#import <WCDB/WCDB.h>` at the top of your Objective-C++ source files and start your WCDB journey.
  7. **Since WCDB is an Objective-C++ framework, for those files in your project that includes WCDB, you should rename their extension `.m` to `.mm`.
* **Via Carthage:** 
  1. Install [Carthage][install-carthage];
  2. Add `github "Tencent/WCDB"` to your Cartfile;
  3. Run `carthage update`.
  4. Drag `WCDB.framework` from the appropriate platform directory in `Carthage/Build/` to the `Linked Binary and Libraries` section of your Xcode project’s `Build Phases` settings;
  5. On your application targets' `Build Phases` settings tab, click the "+" icon and choose `New Run Script Phase`. Create a Run Script with  `carthage copy-frameworks` and add the paths to the frameworks under `Input Files`: `$(SRCROOT)/Carthage/Build/iOS/WCDB.framework` or `$(SRCROOT)/Carthage/Build/Mac/WCDB.framework`;
  6. Add `#import <WCDB/WCDB.h>` at the top of your Objective-C++ source files and start your WCDB journey.
  7. **Since WCDB is an Objective-C++ framework, for those files in your project that includes WCDB, you should rename their extension `.m` to `.mm`.**
* **Via Dynamic Framework**: 
  **Note that Dynamic frameworks are not compatible with iOS 7. See “Static Framework” for iOS 7 support.**
  1. Getting source code from git repository and update the submodule of sqlcipher.
     - `git clone https://github.com/Tencent/wcdb.git`
     - `cd wcdb`
     - `git submodule update --init sqlcipher ` 
  2. Drag `WCDB.xcodeproj` in `wcdb/apple/` into your project;
  3. Add `WCDB.framework` to the `Enbedded Binaries` section of your Xcode project's `General settings`; **Note that there are two frameworks here and the dynamic one should be chosen. You can check it at `Build Phases`->`Target Dependencies`. The right one is `WCDB` while `WCDB iOS Static is used for static lib.**
  4. Add `#import <WCDB/WCDB.h>` at the top of your Objective-C++ source files and start your WCDB journey.
  5. **Since WCDB is an Objective-C++ framework, for those files in your project that includes WCDB, you should rename their extension `.m` to `.mm`.**
* **Via Static Framework:**
  1. Getting source code from git repository and update the submodule of sqlcipher.
     - `git clone https://github.com/Tencent/wcdb.git`
     - `cd wcdb`
     - `git submodule update --init sqlcipher ` 
  2. Drag `WCDB.xcodeproj` in `wcdb/apple/` into your project;
  3. Add `WCDB iOS Static` to the `Target Dependencies` section of your Xcode project's `Build Phases` settings;
  4. Add `WCDB.framework`， `libz.tbd` to the `Linked Binary and Libraries` section of your Xcode project's `Build Phases` settings; Note that there are two `WCDB.framework`, you should choose the one from `WCDB iOS Static` target.
  5. Add `-all_load` and `-ObjC` to the `Other Linker Flags` section of your Xcode project's `Build Settings`.
  6. Add `#import <WCDB/WCDB.h>` at the top of your Objective-C++ source files and start your WCDB journey.
  7. **Since WCDB is an Objective-C++ framework, for those files in your project that includes WCDB, you should rename their extension `.m` to `.mm`.**

## Tutorials

Tutorials can be found [here][iOS-tutorial].

## Documentations

* Documentations can be found on [our Wiki][wcdb-wiki].
* API references for iOS/macOS can be found [here][wcdb-docs-ios].
* Performence data can be found on [our benchmark][Benchmark-iOS].

# WCDB for Android

## Features

* Database encryption via [SQLCipher][sqlcipher].
* ORM/persistence solution via [Room][room] from Android Architecture Components.
* Concurrent access via connection pooling from modern Android framework.
* Repair toolkit for database corruption recovery.
* Database backup and recovery utility optimized for small backup size.
* Log redirection and various tracing facilities.
* API 12 (Android 3.1) and above are supported.

## Getting Started

To include WCDB to your project, choose either way: import via Maven or via AAR package. 

### Import via Maven

To import WCDB via Maven repositories, add the following lines to `build.gradle` on your
app module: 

```gradle
dependencies {
    compile 'com.tencent.wcdb:wcdb-android:1.0.5'
    // Replace "1.0.2" to any available version.
}
```

This will cause Gradle to download AAR package from jcenter while building your application.

If you want to use Room persistence library, you need to add the Google Maven repository to
`build.gradle` to your **root project**.

```gradle
allprojects {
    repositories {
        jcenter()
        // add the following line
        maven { url 'https://maven.google.com' }
    }
}
```

Also add dependencies to module `build.gradle`.

```gradle
dependencies {
    compile 'com.tencent.wcdb:wcdb-room:1.0.3'
    // Replace "1.0.3" to any available version.

    annotationProcessor 'android.arch.persistence.room:compiler:1.0.0-alpha5'
}
```

### Import Prebuilt AAR Package

  1. **Download AAR package from release page.**
  2. **Import the AAR as new module.** In Android Studio, select `File -> New -> New Module...` menu and choose `"Import JAR/AAR Package"`.
  3. **Add a dependency on the new module.** This can be done using `File -> Project Structure...` in Android Studio, or by adding following code to application's `build.gradle`:
```gradle
dependencies {
    // Change "wcdb" to the actual module name specified in step 2.
    compile project(':wcdb')
}
```

### Migrate from Plain-text SQLite Databases

WCDB has interfaces very similar to Android SQLite Database APIs. To migrate you application from
AOSP API, change import path from `android.database.*` to `com.tencent.wcdb.*`, and 
`android.database.sqlite.*` to `com.tencent.wcdb.database.*`. After import path update, 
your application links to WCDB instead of AOSP API.

To open or create an encrypted database, use with-password versions of 
`SQLiteDatabase.openOrCreateDatabase()`, `SQLiteOpenHelper.getWritableDatabase()`, 
or `Context.openOrCreateDatabase()`.

*Note: WCDB uses `byte[]` for password instead of `String` in SQLCipher Android Binding.*

```java
String password = "MyPassword";
SQLiteDatabase db = SQLiteDatabase.openOrCreateDatabase("/path/to/database", password.getBytes(), 
        null, null);
```

See `sample-encryptdb` for sample for transferring data between plain-text and encrypted
databases.

### Use WCDB with Room

To use WCDB with Room library, follow the [Room instructions][room]. The only code to change
is specifying `WCDBOpenHelperFactory` when getting instance of the database.

```java
SQLiteCipherSpec cipherSpec = new SQLiteCipherSpec()
        .setPageSize(4096)
        .setKDFIteration(64000);

WCDBOpenHelperFactory factory = new WCDBOpenHelperFactory()
        .passphrase("passphrase".getBytes())  // passphrase to the database, remove this line for plain-text
        .cipherSpec(cipherSpec)               // cipher to use, remove for default settings
        .writeAheadLoggingEnabled(true);      // enable WAL mode, remove if not needed

AppDatabase db = Room.databaseBuilder(this, AppDatabase.class, "app-db")
                .allowMainThreadQueries()
                .openHelperFactory(factory)   // specify WCDBOpenHelperFactory when opening database
                .build();
```

See `sample-persistence` for sample using Room library.

### Corruption Recovery

See `sample-repairdb` for instructions how to recover corrupted databases using `RepairKit`.

### Redirect Log Output

By default, WCDB prints its log message to system logcat. You may want to change this
behavior in order to, for example, save logs for troubleshooting. WCDB can redirect
all of its log outputs to user-defined routine using `Log.setLogger(LogCallback)`
method.

## Build from Sources

### Build WCDB Android with Prebuilt Dependencies

WCDB itself can be built apart from its dependencies using Gradle or Android Studio. 
To build WCDB Android library, run Gradle on `android` directory:

```bash
$ cd android
$ ./gradlew build
```

Building WCDB requires Android NDK installed. If Gradle failed to find your SDK and/or 
NDK, you may need to create a file named `local.properties` on the `android` directory 
with content:

```
sdk.dir=path/to/sdk
ndk.dir=path/to/ndk
```

Android Studio will do this for you when the project is imported.

### Build Dependencies from Sources

WCDB depends on OpenSSL crypto library and SQLCipher. You can rebuild all dependencies
if you wish. In this case, a working C compiler on the host system, Perl 5, Tcl and a 
bash environment is needed to be installed on your system.

To build dependencies, checkout all submodules, set `ANDROID_NDK_ROOT` environment 
variable to your NDK path, then run `build-depends-android.sh`:

```bash
$ export ANDROID_NDK_ROOT=/path/to/ndk
$ ./build-depends-android.sh
```

This will build OpenSSL crypto library and generate SQLCipher amalgamation sources
and place them to proper locations suitable for WCDB library building.

## Documentations

* Documentations can be found on [our Wiki][wcdb-wiki].
* API references for Android can be found [here][wcdb-docs-android].

[install-carthage]: https://github.com/Carthage/Carthage#installing-carthage
[wcdb-wiki]: https://github.com/Tencent/wcdb/wiki
[wcdb-docs-ios]: https://tencent.github.io/wcdb/references/ios/index.html
[wcdb-docs-android]: https://tencent.github.io/wcdb/references/android/index.html
[sqlcipher]: https://github.com/sqlcipher/sqlcipher
[room]: https://developer.android.com/topic/libraries/architecture/room.html
[iOS-tutorial]: https://github.com/Tencent/wcdb/wiki/iOS-macOS-Tutorial
[Benchmark-iOS]: https://github.com/Tencent/wcdb/wiki/WCDB-iOS-benchmark

