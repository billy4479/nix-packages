{
  fetchPypi,
  python3Packages,
  ...
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "caveclient";
  version = "8.2.1";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-146HBP75mN7CR8DZ+tuCEcTNwP71TaNfZhPuCFfemSU=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  nativeBuildInputs = with python3Packages; [
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = [
    "pandas"
  ];

  dependencies = with python3Packages; [
    attrs
    cachetools
    h5py
    ipython
    jsonschema
    networkx
    numpy
    packaging
    pandas
    pyarrow
    requests
    urllib3
  ];
})
