{
  fetchPypi,
  python3Packages,
  ...
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "caveclient";
  version = "8.0.1";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-zKjKMgneWZJI6jhvQxVl+0GS2IuEgRpogNEx0r1sAYE=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    attrs
    cachetools
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
