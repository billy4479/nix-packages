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
  upstreamLock = builtins.fromTOML (builtins.readFile "${source.sourcePath}/uv.lock");
  # The locked feder-cr repositories were deleted. The surviving fork retains
  # the complete implementation from before invisible-core was split out.
  invisibleCore = builtins.head (
    builtins.filter (package: package.name == "invisible-core") upstreamLock.package
  );
  uvLock = upstreamLock // {
    package = map (
      package:
      if package.name == "invisible-playwright" then
        package
        // {
          version = "0.2.0";
          source.git = "https://github.com/v8eta/invisible_playwright.git#29262a644eae368f544b005782ce7c54701796c2";
          dependencies =
            builtins.filter (dependency: dependency.name != "invisible-core") package.dependencies
            ++ invisibleCore.dependencies;
        }
      else
        package
    ) (builtins.filter (package: package.name != "invisible-core") upstreamLock.package);
  };

  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = source.sourcePath;
    inherit uvLock;
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

            invisible-playwright = prev.invisible-playwright.overrideAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ final.resolveBuildSystem {
                hatchling = [ ];
              };
            });

            invisible-core = prev.invisible-core.overrideAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ final.resolveBuildSystem {
                hatchling = [ ];
              };
            });

            invisible-useragent = prev.invisible-useragent.overrideAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ final.resolveBuildSystem {
                hatchling = [ ];
                setuptools = [ ];
              };
            });
          })
        ]
      );
in
pythonSet.mkVirtualEnv "byparr-python-env-${version}" {
  fastapi = [ "standard" ];
  invisible-playwright = [ ];
  playwright = [ ];
  "playwright-captcha" = [ ];
  pydantic = [ ];
  pydantic-settings = [ ];
}
