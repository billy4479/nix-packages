# Based on https://github.com/NixOS/nixpkgs/blob/43fbacd0e62377fcac5190d0036a977f1a2b2b11/pkgs/by-name/qi/qimgv/package.nix
{
  lib,
  stdenv,
  fetchFromGitHub,

  extraImageFormats ? true,

  cmake,
  pkg-config,
  ninja,

  qt6,
  exiv2,
  mpv,
  opencv4,
  kdePackages,
}:

stdenv.mkDerivation {
  pname = "qimgv";
  version = "1.0.3-unstable-2025-09-05";

  src = fetchFromGitHub {
    owner = "easymodo";
    repo = "qimgv";
    rev = "6bdfad1f47be2cd5eb54c6da45073f8eee55963f";
    sha256 = "sha256-OsPI9+lKZIRo7QhLwQ3qBs8cm6VwH6sePEH5KhUegVo=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
  ];

  cmakeFlags = [
    "-DVIDEO_SUPPORT=ON"
    "-DUSE_QT5=OFF"
    # TODO: what about "-DKDE_SUPPORT"??
  ];

  buildInputs = [
    exiv2
    mpv
    opencv4.cxxdev
    qt6.qtbase
    qt6.qtimageformats
    qt6.qtsvg
    qt6.qttools
  ]
  ++ lib.optionals extraImageFormats [
    kdePackages.kimageformats
  ];

  postPatch = ''
    sed -i "s@/usr/bin/mpv@${mpv}/bin/mpv@" \
      qimgv/settings.cpp
  '';

  # Wrap the library path so it can see `libqimgv_player_mpv.so`, which is used
  # to play video files within qimgv itself.
  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${placeholder "out"}/lib"
  ];

  meta = with lib; {
    description = "Qt6 image viewer with optional video support";
    mainProgram = "qimgv";
    homepage = "https://github.com/easymodo/qimgv";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
