{
  callPackage,
  lib,
  nodejs,
  pyproject-build-systems,
  pyproject-nix,
  python314,
  source,
  uv2nix,
  version,
  ...
}:

let
  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = source.sourcePath;
  };

  pythonSet =
    (callPackage pyproject-nix.build.packages {
      python = python314;
    }).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.wheel
          (workspace.mkPyprojectOverlay { sourcePreference = "wheel"; })
          (final: prev: {
            byparr = prev.byparr.overrideAttrs (old: {
              # The application sources are shipped by package.nix; this venv
              # only needs Byparr's locked runtime dependencies.
              meta = (old.meta or { }) // {
                broken = true;
              };
            });

            "playwright-captcha" =
              (prev."playwright-captcha".override { sourcePreference = "sdist"; }).overrideAttrs (old: {
                prePatch = (old.prePatch or "") + ''
                  sed -i 's/\r$//' playwright_captcha/utils/camoufox_add_init_script/add_init_script.py
                '';
                patches = (old.patches or [ ]) ++ [ ./patches/playwright-captcha-writable-addon.patch ];
                postPatch = (old.postPatch or "") + ''
                  rm -f playwright_captcha/utils/camoufox_add_init_script/add_init_script.py.orig
                  rm -rf playwright_captcha/utils/camoufox_add_init_script/__pycache__
                '';
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ final.resolveBuildSystem {
                  setuptools = [ ];
                };
              });
          })
        ]
      );
in
(pythonSet.mkVirtualEnv "byparr-python-env-${version}" {
  fastapi = [ "standard" ];
  invisible-playwright = [ ];
  playwright = [ ];
  "playwright-captcha" = [ ];
  pydantic = [ ];
  pydantic-settings = [ ];
  trafilatura = [ ];
}).overrideAttrs
  (prev: {
    # Playwright wheels bundle a prebuilt node binary to run the driver.
    # Nix ELF post-processing corrupts it: the patched binary ends up with
    # overlapping PT_LOAD segments whose later read-only mapping replaces the
    # read-write one, so ld.so segfaults in dl_main writing DT_DEBUG and every
    # browser launch dies with "Connection closed while reading from the
    # driver" (this is why all Byparr solves 500'd from 2026-10-23). Run the
    # driver with a Nix-built nodejs instead, like nixpkgs' playwright package
    # does via driver-location.patch.
    postInstall =
      (prev.postInstall or "")
      + ''
        chmod -R u+w "$out/${python314.sitePackages}/playwright/driver"
        rm "$out/${python314.sitePackages}/playwright/driver/node"
        ln -s "${lib.getExe nodejs}" "$out/${python314.sitePackages}/playwright/driver/node"
      '';
  })
