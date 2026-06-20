{
  fetchurl,
  stdenvNoCC,
  unzip,
}:

let
  camoufoxBrowser = fetchurl {
    url = "https://github.com/daijro/camoufox/releases/download/v135.0.1-beta.24/camoufox-135.0.1-beta.24-lin.x86_64.zip";
    hash = "sha256-YeHsRV4CFyCvOKXMX/dWYSE2PLW4K3LyTjgbomdqSIg=";
  };

  geolite = fetchurl {
    url = "https://github.com/P3TERX/GeoLite.mmdb/releases/download/2026.06.19/GeoLite2-City.mmdb";
    hash = "sha256-w0k6GVVsV0PSXBfuPNS9LXZoQe18fWJC/rHKro9inPs=";
  };

  ublockOrigin = fetchurl {
    url = "https://addons.mozilla.org/firefox/downloads/file/4560539/ublock_origin-1.71.0.xpi";
    hash = "sha256-efpsNBoQFf8xzi2JjTRF2ovJoYIFI9Av4GP2OCtYPhU=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "byparr-camoufox";
  version = "135.0.1-beta.24";

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
    printf '{"version":"135.0.1","release":"beta.24"}' > "$out/version.json"
    chmod -R u+rwX,go+rX "$out"
    runHook postInstall
  '';

  passthru = {
    inherit geolite ublockOrigin;
  };
}
