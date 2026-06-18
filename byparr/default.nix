{
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fetchFromGitHub,
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
  nspr,
  nss,
  pango,
  patchelf,
  python314,
  python314Packages,
  stdenv,
  stdenvNoCC,
  udev,
  uv,
  zlib,
  ...
}:

let
  version = "2.1.0";
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

  payload = stdenvNoCC.mkDerivation {
    pname = "byparr-payload";
    inherit version;

    src = fetchFromGitHub {
      owner = "ThePhaseless";
      repo = "Byparr";
      rev = "v${version}";
      hash = "sha256-6XlhQJI/TBYXbojivBp+dFXJDcuBsY6ZLwLwTw+YqMA=";
    };

    nativeBuildInputs = [
      python314
      python314Packages.pip
      uv
    ];

    buildPhase = # sh
      ''
        runHook preBuild

        export HOME="$TMPDIR/home"
        export XDG_CACHE_HOME="$TMPDIR/cache"
        export UV_LINK_MODE=copy
        export UV_PYTHON="${python314}/bin/python"
        export LD_LIBRARY_PATH="${runtimeLibraryPath}"

        mkdir -p "$HOME" "$XDG_CACHE_HOME"

        uv export --frozen --no-dev --no-emit-project --format requirements.txt --output-file requirements.txt
        python -m pip download --dest wheelhouse --requirement requirements.txt

        # Build a temporary environment only to download Camoufox runtime assets.
        uv sync --frozen --no-dev
        uv run --no-sync camoufox fetch
        uv run --no-sync python -c 'from camoufox.locale import download_mmdb; download_mmdb()'
        find . "$XDG_CACHE_HOME" -type d -name __pycache__ -prune -exec rm -rf {} +

        runHook postBuild
      '';

    installPhase = # sh
      ''
        runHook preInstall

        mkdir -p "$out/source" "$out/cache" "$out/wheelhouse"
        cp -R . "$out/source"
        rm -rf "$out/source/.venv" "$out/source/wheelhouse"
        rm -f "$out/source/test.sh"
        cp -R wheelhouse/. "$out/wheelhouse"
        cp .venv/lib/python3.14/site-packages/camoufox/GeoLite2-City.mmdb "$out/GeoLite2-City.mmdb"
        if [ -d "$XDG_CACHE_HOME/camoufox" ]; then
          cp -R "$XDG_CACHE_HOME/camoufox" "$out/cache/camoufox"
        fi

        runHook postInstall
      '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-oe1LVTpyjnA+YOUHpnQNux4y3Agrik6lsT7MC8ceYnM=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "byparr";
  inherit version;

  nativeBuildInputs = [
    patchelf
    python314
    uv
  ];

  buildInputs = [
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

  dontUnpack = true;

  buildPhase = # sh
    ''
      runHook preBuild

      cp -R "${payload}/source" app
      chmod -R u+w app
      cd app

      export HOME="$TMPDIR/home"
      export XDG_CACHE_HOME="$TMPDIR/cache"
      export UV_LINK_MODE=copy
      export UV_PYTHON="${python314}/bin/python"
      export LD_LIBRARY_PATH="${runtimeLibraryPath}"

      mkdir -p "$HOME" "$XDG_CACHE_HOME"
      uv venv --python "${python314}/bin/python" .venv
      uv pip install --python .venv/bin/python --no-index --find-links "${payload}/wheelhouse" --requirement requirements.txt
      cp "${payload}/GeoLite2-City.mmdb" .venv/lib/python3.14/site-packages/camoufox/GeoLite2-City.mmdb
      awk '
        NR == 12 {
          print "    cache_dir = Path(os.environ.get(\"BYPARR_CACHE_DIR\", os.environ.get(\"XDG_CACHE_HOME\", \"/tmp/byparr-cache\")))"
          print "    addon_path = cache_dir / \"playwright-captcha-addon\""
          print "    if not addon_path.exists():"
          print "        import shutil"
          print "        shutil.copytree(Path(__file__).parent / \"addon\", addon_path)"
          print "        for root, dirs, files in os.walk(addon_path):"
          print "            for name in dirs + files:"
          print "                os.chmod(Path(root) / name, 0o700)"
          print "        os.chmod(addon_path, 0o700)"
          print ""
          print "    return str(addon_path.resolve())"
          next
        }
        NR >= 13 && NR <= 16 { next }
        { print }
      ' .venv/lib/python3.14/site-packages/playwright_captcha/utils/camoufox_add_init_script/add_init_script.py > add_init_script.py.tmp
      mv add_init_script.py.tmp .venv/lib/python3.14/site-packages/playwright_captcha/utils/camoufox_add_init_script/add_init_script.py
      patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
        --set-rpath "${runtimeLibraryPath}" \
        .venv/lib/python3.14/site-packages/playwright/driver/node
      find . -type d -name __pycache__ -prune -exec rm -rf {} +

      runHook postBuild
    '';

  installPhase = # sh
    ''
      runHook preInstall

      mkdir -p "$out/bin" "$out/app" "$out/share/byparr"
      cp -R . "$out/app"
      cp -R "${payload}/cache" "$out/share/byparr/cache"
      chmod -R u+w "$out/share/byparr/cache"
      patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
        --set-rpath "${runtimeLibraryPath}:\$ORIGIN" \
        "$out/share/byparr/cache/camoufox/camoufox-bin"
      cat >"$out/bin/byparr" <<EOF
      #!${stdenvNoCC.shell}
      export HOME=\''${HOME:-/tmp/byparr-home}
      export XDG_CACHE_HOME=\''${BYPARR_CACHE_DIR:-/tmp/byparr-cache}
      export PYTHONUNBUFFERED=1
      export PYTHONDONTWRITEBYTECODE=1
      export LD_LIBRARY_PATH="\$XDG_CACHE_HOME/camoufox:${runtimeLibraryPath}:\''${LD_LIBRARY_PATH:-}"
      mkdir -p "\$HOME" "\$XDG_CACHE_HOME"
      if [ ! -d "\$XDG_CACHE_HOME/camoufox" ]; then
        cp -R "$out/share/byparr/cache/camoufox" "\$XDG_CACHE_HOME/camoufox"
        chmod -R u+rwX "\$XDG_CACHE_HOME/camoufox"
      fi
      cd "$out/app"
      exec "$out/app/.venv/bin/python" main.py "\$@"
      EOF
      chmod +x "$out/bin/byparr"

      runHook postInstall
    '';
}
