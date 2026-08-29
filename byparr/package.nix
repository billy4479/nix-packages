{
  geoip,
  lib,
  makeWrapper,
  pythonEnv,
  source,
  stdenvNoCC,
  stealthfox,
  version,
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

    makeWrapper "${pythonEnv}/bin/python" "$out/bin/byparr" \
      --chdir "$out/app" \
      --set-default VERSION "${version}" \
      --set INVISIBLE_PLAYWRIGHT_CACHE_DIR "${stealthfox}" \
      --set STEALTHFOX_GEOIP_MMDB "${geoip}" \
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

  meta = {
    mainProgram = "byparr";
  };
}
