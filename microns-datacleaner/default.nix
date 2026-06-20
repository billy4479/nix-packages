{
  fetchFromGitHub,
  python3Packages,

  standard_transform,
  caveclient,
  ...
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "microns-combiner";
  version = "0.3.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "MICrONS-Milano-CoLab";
    repo = "MICrONS-combiner";
    rev = "ff78bcdcf223f51deebb31c64cb64e025e0b3350";
    hash = "sha256-mkTXN0iPFbwmAkPmp0NSSgI6YbLXjFYHOUc4u2pZyU4=";
  };

  build-system = with python3Packages; [
    poetry-core
  ];

  nativeBuildInputs = with python3Packages; [
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = [
    "numpy"
  ];

  dependencies = with python3Packages; [
    numpy
    standard_transform
    matplotlib
    pandas
    caveclient
    tqdm
    scipy
    h5py
    pyyaml
  ];
})
