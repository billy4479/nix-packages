{
  geoip,
  lib,
  makeWrapper,
  nodejs,
  pythonEnv,
  source,
  stdenvNoCC,
  stealthfox,
  version,
  writeShellScript,
  xorg-server,
}:

stdenvNoCC.mkDerivation {
  pname = "byparr";
  inherit version;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/app"
    cp -R "${source.sourcePath}/." "$out/app"
    rm -f "$out/app/test.sh"

    # Playwright wheels ship a prebuilt node for the driver whose ELF gets
    # corrupted by Nix ELF post-processing (overlapping PT_LOAD segments ->
    # ld.so segfaults in dl_main writing DT_DEBUG before main runs). Point
    # playwright at a Nix-built nodejs instead: _driver.py checks
    # PLAYWRIGHT_NODEJS_PATH before falling back to the bundled binary.
    makeWrapper "${pythonEnv}/bin/python" "$out/bin/byparr" \
      --chdir "$out/app" \
      --set-default VERSION "${version}" \
      --set INVISIBLE_PLAYWRIGHT_CACHE_DIR "${stealthfox}" \
      --set STEALTHFOX_GEOIP_MMDB "${geoip}" \
      --set-default PLAYWRIGHT_NODEJS_PATH "${lib.getExe nodejs}" \
      --set-default HOME /tmp/byparr-home \
      --set-default XDG_CACHE_HOME /tmp/byparr-cache \
      --run "mkdir -p /tmp/byparr-cache/invisible-playwright-fonts" \
      --set PYTHONUNBUFFERED 1 \
      --set PYTHONDONTWRITEBYTECODE 1 \
      --prefix PATH : "${lib.makeBinPath [ xorg-server ]}" \
      --prefix LD_LIBRARY_PATH : "${stealthfox}/engine:${stealthfox.runtimeLibraryPath}" \
      --add-flags main.py

    runHook postInstall
  '';

  passthru = {
    updateScript = import ../lib/make-update-script.nix {
      inherit writeShellScript;
      pkgPath = ./.;
      name = "update-byparr";
    };
  };

  meta = {
    mainProgram = "byparr";
  };
}
