{
  fetchFromGitHub,
  python3Packages,

  standard_transform,
  caveclient,
  ...
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "microns-datacleaner";
  version = "0.2.1.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "MICrONS-Milano-CoLab";
    repo = "MICrONS-datacleaner";
    rev = "b2d83643f6961c021b50390a81879927a8f9720a";
    hash = "sha256-a5LG+3yHzOXQPW/+qtEKu6lQiZonRWbEKptL0tl4+/k=";
  };

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    numpy
    standard_transform
    pandas
    caveclient
    tqdm
    scipy
    h5py
    pyyaml
  ];
})
