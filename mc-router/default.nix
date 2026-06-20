{
  buildGoModule,
  fetchFromGitHub,

  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "mc-router";
  version = "1.43.1";

  src = fetchFromGitHub {
    owner = "itzg";
    repo = "mc-router";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AyhAwdWsSg9jG36JHvDqDQ/2kC8NzCVIqKtjaXC9qjc=";
  };

  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "go 1.26.4" "go 1.26.3"
  '';

  vendorHash = "sha256-DLVRgeNr1aYz4gJYpZNorFx/GEmtWZ11VVEZTRZwx4M=";

  meta = {
    description = "Routes Minecraft client connections to backend servers based upon the requested server address";
    homepage = "https://github.com/itzg/mc-router";
    license = lib.licenses.mit;
  };

})
