{ lib
, mkShell
, androidsdk
, jdk17
, flutter
, qemu_kvm
, gradle
, vulkan-loader
, libGL
, gtk3
, pkg-config
, pcre2
, util-linux
, libselinux
, libsepol
, libthai
, libdatrie
, xorg
, lerc
, libxkbcommon
, libepoxy
}: mkShell {

  packages = [
    androidsdk
    flutter
    qemu_kvm
    gradle
    jdk17
  ];

  buildInputs = [
    # emulator hwdecode
    vulkan-loader
    libGL

    # build shell hook
    pkg-config

    # needed to not crash
    gtk3

    # fixes nagging
    pcre2.dev
    util-linux.dev
    libselinux
    libsepol
    libthai
    libdatrie
    xorg.libXdmcp
    xorg.libXtst
    lerc.dev
    libxkbcommon
    libepoxy
  ];

  # # emulator related: vulkan-loader and libGL shared libs are necessary for hardware decoding
  # LD_LIBRARY_PATH = "${lib.makeLibraryPath [vulkan-loader libGL ]}";

  ANDROID_HOME = "${androidsdk}/libexec/android-sdk";
  ANDROID_SDK_ROOT = "${androidsdk}/libexec/android-sdk";
  JAVA_HOME = jdk17.home;
  FLUTTER_ROOT = flutter;
  DART_ROOT = "${flutter}/bin/cache/dart-sdk";
  GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidsdk}/libexec/android-sdk/build-tools/33.0.2/aapt2";
  QT_QPA_PLATFORM = "wayland;xcb"; # emulator related: try using wayland, otherwise fall back to X.
  # NB: due to the emulator's bundled qt version, it currently does not start with QT_QPA_PLATFORM="wayland".
  # Maybe one day this will be supported.
} 
