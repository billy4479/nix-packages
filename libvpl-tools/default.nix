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
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "libvpl-tools";
    rev = "3de25bf3358de6d68633aeb915a2564808197315";
    sha256 = "sha256-0nE3cAUzdArf1QOsbFhBowaTqTVkNk4ZhJKJz311H6s=";
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
