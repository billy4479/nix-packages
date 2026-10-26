{
  lib,
  fetchFromGitHub,
  python3Packages,
  writeShellScript,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "wa-crypt-tools";
  # The newest release tag is v0.1.0; master carries version 0.2.0 in
  # pyproject.toml, so the base version follows it and the date marks the
  # tracked commit.
  version = "0.2.0-unstable-2026-10-06";

  src = fetchFromGitHub {
    owner = "ElDavoo";
    repo = "wa-crypt-tools";
    rev = "b16a805a394b8e243334f286dcf30f262e60db4f";
    hash = "sha256-L/HL3l9VR02qLhOoGYgsz/bYb/cSLDEXw0U5ZFDlszE=";
  };

  pyproject = true;

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    javaobj-py3
    protobuf
    pycryptodomex
    # Split out of the interpreter in current nixpkgs; wagui needs it.
    tkinter
  ];

  doCheck = true;
  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  # tests/tools-invocation runs the console scripts as subprocesses.
  preCheck = ''
    export PATH="$out/bin:$PATH"
  '';

  passthru.updateScript = import ../lib/make-update-script.nix {
    inherit writeShellScript;
    pkgPath = ./.;
    name = "update-wa-crypt-tools";
  };

  meta = {
    description = "Manages WhatsApp .crypt12, .crypt14 and .crypt15 files, given the key";
    homepage = "https://github.com/ElDavoo/wa-crypt-tools";
    license = lib.licenses.gpl3Plus;
    mainProgram = "wadecrypt";
  };
})
