{
  buildGoModule,
  fetchFromGitHub,

  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "mc-router";
  version = "1.40.1";

  src = fetchFromGitHub {
    owner = "itzg";
    repo = "mc-router";
    rev = "v${finalAttrs.version}";
    hash = "sha256-h5lIALmU8ZBXF/mJiSmm6/qUbOJF4YWkIq3hYPdZlEY=";
  };

  vendorHash = "sha256-js1boC25AsHO9V9m0uei2XhW+NPPybyfNdGZ7NtAT24=";

  meta = {
    description = "Routes Minecraft client connections to backend servers based upon the requested server address";
    homepage = "https://github.com/itzg/mc-router";
    license = lib.licenses.mit;
  };

})
