{ androidenv, ... }: (androidenv.composeAndroidPackages {
  # https://developer.android.com/tools
  cmdLineToolsVersion = "3.0";
  buildToolsVersions = [ "34.0.0" ];
  platformToolsVersion = "33.0.3";
  emulatorVersion = "31.3.10";
  platformVersions = [ "34" ];
  toolsVersion = null;
  includeEmulator = true;
  # per platform version
  includeSystemImages = false;
  includeSources = false;
  useGoogleAPIs = false;
  useGoogleTVAddOns = false;
  # systemImageTypes = [ "google_apis_playstore" ];
  abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
  cmakeVersions = [ "3.22.1" ];
  includeNDK = true;
  ndkVersions = [ "26.3.11579264" ];
  # includeExtras = [
  #   "extras;google;gcm"
  # ];
}).androidsdk
