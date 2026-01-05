{
  lib,
  stdenv,
  fetchFromGitHub,

  cmake,
  pkg-config,
  ninja,

  libvpl,
  libva,
  libdrm,
  libX11,
  libXext,
  libXfixes,
  libxcb,
  libxdmcp,
  wayland,
  wayland-scanner,
  wayland-protocols,
  gtkmm4,
  libsysprof-capture,
  libepoxy,
  libpciaccess,
}:

stdenv.mkDerivation {
  pname = "libvpl-tools";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "libvpl-tools";
    rev = "ad9deecaf0ee76f689373b55fe620c843e3c8a4d";
    sha256 = "sha256-s0ogz9Bkq0RRJ72vChqoA2NpEf3X+Hpn24aXO+2WI7U=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  cmakeFlags = [
    "-DCMAKE_PREFIX_PATH=${libvpl}"
    "-DENABLE_WAYLAND=ON"
    "-DENABLE_GTK4=ON"
  ];

  buildInputs = [
    libvpl
    libva
    libdrm
    libX11
    libXext
    libXfixes
    libxcb
    libxdmcp
    wayland
    wayland-scanner
    wayland-protocols
    gtkmm4
    libsysprof-capture
    libepoxy
    libpciaccess
  ];

  meta = with lib; {
    description = "Intel® Video Processing Library (Intel® VPL) Tools";
    homepage = "https://github.com/intel/libvpl-tools";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
