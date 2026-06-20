{
  callPackage,
  lib,
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

            camoufox = (prev.camoufox.override { sourcePreference = "sdist"; }).overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [ ./patches/camoufox-cache-paths.patch ];
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ final.resolveBuildSystem {
                poetry-core = [ ];
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
pythonSet.mkVirtualEnv "byparr-python-env-${version}" {
  camoufox = [ "geoip" ];
  fastapi = [ "standard" ];
  "playwright-captcha" = [ ];
  pydantic = [ ];
}
