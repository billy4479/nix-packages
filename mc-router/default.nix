{
  buildGoModule,
  fetchFromGitHub,

  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "mc-router";
  version = "1.47.1";

  src = fetchFromGitHub {
    owner = "itzg";
    repo = "mc-router";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5rwIFnfsHKYTOE0F7UB9rO3fjk3VtU7YE/8q6uYYUDE=";
  };

  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "go 1.26.6" "go 1.26.3"
  '';

  vendorHash = "sha256-cw9DHGctLp7+PjNlLgwWhAXpK30kRhv2N1Qkn/cTPYU=";

  meta = {
    description = "Routes Minecraft client connections to backend servers based upon the requested server address";
    homepage = "https://github.com/itzg/mc-router";
    license = lib.licenses.mit;
  };

})
