{
  fetchPypi,
  python3Packages,
  ...
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "caveclient";
  version = "8.1.0";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-t3mtzooUqLbKPY51ElTPw1jzHxPtvfs3NT8qx3oCYsI=";
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
