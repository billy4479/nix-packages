{
  buildGoModule,
  fetchFromGitHub,

  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "mc-router";
  version = "1.44.0";

  src = fetchFromGitHub {
    owner = "itzg";
    repo = "mc-router";
    rev = "v${finalAttrs.version}";
    hash = "sha256-sEXT/wllbLLByjV88Ul3oXAV7qS10HmqB7Inu54Ob+0=";
  };

  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "go 1.26.4" "go 1.26.3"
  '';

  vendorHash = "sha256-r608oS6gOsOBcaHk8w/aoqtst9ZJvhx3d7+T5KsG79M=";

  meta = {
    description = "Routes Minecraft client connections to backend servers based upon the requested server address";
    homepage = "https://github.com/itzg/mc-router";
    license = lib.licenses.mit;
  };

})
