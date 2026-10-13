{
  buildGoModule,
  fetchFromGitHub,

  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "mc-router";
  version = "1.47.2";

  src = fetchFromGitHub {
    owner = "itzg";
    repo = "mc-router";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2gd+F5abyaDr1FvipiD7eoX8VGtdGXMjD4sjAVK39lc=";
  };

  vendorHash = "sha256-m+g2zPUiLF03U3lrE49QE8uZoqcyGPTTjvs2s6E1mPA=";

  meta = {
    description = "Routes Minecraft client connections to backend servers based upon the requested server address";
    homepage = "https://github.com/itzg/mc-router";
    license = lib.licenses.mit;
  };

})
