{
  buildGoModule,
  fetchFromGitHub,
  go_1_27,

  lib,
  writeShellScript,
}:
(buildGoModule.override { go = go_1_27; }) (finalAttrs: {
  pname = "derper";
  version = "1.104.2";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "tailscale";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vMkNFJSwf/UPCUnMZiFd+cfOspdvHMU4GPs/LAqxib0=";
  };

  subPackages = [ "cmd/derper" ];

  vendorHash = "sha256-VxuDS8QKZ82W/MOlfng0+ZCPSPl5KnK3FYW1puDiNe4=";

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
