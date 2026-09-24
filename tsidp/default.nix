{
  buildGoModule,
  fetchFromGitHub,

  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "tsidp";
  version = "unstable-2026-09-24";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "tsidp";
    rev = "8fa860f333d9b0ed7eee66e0c7c08531f743fd16";
    hash = "sha256-PaMhJH7Zx+jSZ6HHMzYEMovE1ZsbvZzLdZKgNIu4VKY=";
  };

  vendorHash = "sha256-/7L5Be2H3XHHgC5So/cTYekb1sxil8iwDB+9nlPP56A=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/tailscale/tsidp/server.version=${finalAttrs.version}"
  ];

  doCheck = true;

  meta = {
    description = "Tailscale OIDC Identity Provider";
    homepage = "https://github.com/tailscale/tsidp";
    license = lib.licenses.bsd3;
    mainProgram = "tsidp";
  };
})
