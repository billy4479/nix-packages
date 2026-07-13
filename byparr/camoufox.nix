{
  fetchurl,
  stdenvNoCC,
  unzip,
}:

let
  camoufoxBrowser = fetchurl {
    url = "https://github.com/daijro/camoufox/releases/download/v150.0.2-beta.25/camoufox-150.0.2-alpha.26-lin.x86_64.zip";
    hash = "sha256-sUa5iwwsQQI3Fv7vNkUfMZpTQwn3LFRYSksLiGcPUQs=";
  };

  geolite = fetchurl {
    url = "https://github.com/P3TERX/GeoLite.mmdb/releases/download/2026.07.13/GeoLite2-City.mmdb";
    hash = "sha256-FosB0Q0HQhKb4b7pK7qFr/qu/PLoa0GHvPGSTqUAaL8=";
  };

  ublockOrigin = fetchurl {
    url = "https://addons.mozilla.org/firefox/downloads/file/4872816/ublock_origin-1.72.0.xpi";
    hash = "sha256-ec1CarWZgBxZ3+mJXLS4AC+vPaBZ9xEcJyGsEBaKO2Q=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "byparr-camoufox";
  version = "150.0.2-alpha.26";

  inherit geolite ublockOrigin;

  src = camoufoxBrowser;

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack
    unzip -q "$src" || test "$?" = 1
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -R . "$out"
    mkdir -p "$out/addons/UBO"
    unzip -q "${ublockOrigin}" -d "$out/addons/UBO"
    printf '{"version":"150.0.2","release":"alpha.26"}' > "$out/version.json"
    chmod -R u+rwX,go+rX "$out"
    runHook postInstall
  '';

  passthru = {
    inherit geolite ublockOrigin;
  };
}
