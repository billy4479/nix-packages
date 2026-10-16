{
  buildGoModule,
  fetchFromGitHub,
  go_1_27,

  lib,
  writeShellScript,
}:
(buildGoModule.override { go = go_1_27; }) (finalAttrs: {
  pname = "derper";
  version = "1.104.1";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "tailscale";
    rev = "v${finalAttrs.version}";
    hash = "sha256-f80GVxstQrr8ENP1bseoIpLflQ+QYEisDF8PHzTs7Lg=";
  };

  subPackages = [ "cmd/derper" ];

  vendorHash = "sha256-f9abuyk1qvVr6MPpfmHay6p/U/+8flm1SBmHGjZa1aU=";

  ldflags = [
    "-s"
    "-w"
    "-X tailscale.com/version.longStamp=${finalAttrs.version}"
    "-X tailscale.com/version.shortStamp=${finalAttrs.version}"
  ];

  passthru.updateScript = import ../lib/make-update-script.nix {
    inherit writeShellScript;
    pkgPath = ./.;
    name = "update-derper";
  };

  meta = {
    description = "Standalone Tailscale DERP relay and STUN server";
    homepage = "https://github.com/tailscale/tailscale";
    license = lib.licenses.bsd3;
    mainProgram = "derper";
  };
})
