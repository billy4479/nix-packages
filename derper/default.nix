{
  buildGoModule,
  fetchFromGitHub,

  lib,
  ...
}:
buildGoModule (finalAttrs: {
  pname = "derper";
  version = "1.102.4";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "tailscale";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PCCkzNvV9AK1AM5UhM97roSctctvFfwUw5QhKB64n00=";
  };

  subPackages = [ "cmd/derper" ];

  vendorHash = "sha256-amKkUPszyhG4N5ZtrB01swBACYq76raSS+SQRneLmwc=";

  ldflags = [
    "-s"
    "-w"
    "-X tailscale.com/version.longStamp=${finalAttrs.version}"
    "-X tailscale.com/version.shortStamp=${finalAttrs.version}"
  ];

  meta = {
    description = "Standalone Tailscale DERP relay and STUN server";
    homepage = "https://github.com/tailscale/tailscale";
    license = lib.licenses.bsd3;
    mainProgram = "derper";
  };
})
