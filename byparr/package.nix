{
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  camoufox,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  glib,
  gtk3,
  lib,
  libGL,
  libdrm,
  libx11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  libxcb,
  makeWrapper,
  nspr,
  nss,
  pango,
  patchelf,
  pythonEnv,
  source,
  stdenv,
  stdenvNoCC,
  udev,
  version,
  zlib,
  ...
}:

let
  runtimeLibraryPath = lib.makeLibraryPath [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    glib
    gtk3
    libGL
    libdrm
    libxkbcommon
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    udev
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxtst
    libxcb
    zlib
  ];
in
stdenvNoCC.mkDerivation {
  pname = "byparr";
  inherit version;

  nativeBuildInputs = [
    makeWrapper
    patchelf
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/app" "$out/share/byparr"
    cp -R "${source.sourcePath}/." "$out/app"
    rm -f "$out/app/test.sh"

    cp -R "${camoufox}/." "$out/share/byparr/camoufox"
    if [ -e "$out/share/byparr/camoufox/camoufox-bin" ]; then
      chmod -R u+w "$out/share/byparr/camoufox"
      patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
        --set-rpath "${runtimeLibraryPath}:\$ORIGIN" \
        "$out/share/byparr/camoufox/camoufox-bin"
    fi

    makeWrapper "${pythonEnv}/bin/python" "$out/bin/byparr" \
      --chdir "$out/app" \
      --set CAMOUFOX_CACHE_DIR "$out/share/byparr/camoufox" \
      --set CAMOUFOX_GEOLITE2_CITY "${camoufox.geolite}" \
      --set-default HOME /tmp/byparr-home \
      --set-default XDG_CACHE_HOME /tmp/byparr-cache \
      --set PYTHONUNBUFFERED 1 \
      --set PYTHONDONTWRITEBYTECODE 1 \
      --prefix LD_LIBRARY_PATH : "$out/share/byparr/camoufox:${runtimeLibraryPath}" \
      --add-flags main.py

    runHook postInstall
  '';

  meta = {
    mainProgram = "byparr";
  };
}
