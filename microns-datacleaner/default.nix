{
  fetchFromGitHub,
  python3Packages,

  standard_transform,
  caveclient,
  ...
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "caveclient";
  version = "8.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "MICrONS-Milano-CoLab";
    repo = "MICrONS-datacleaner";
    rev = "d1be915073200a4c644be02c66c89ecb81df782b";
    hash = "sha256-ZEUjTjlxTlUp8D07gvqZvoNtmEpsgKUTWlWRWD59J14=";
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
  ];
})
