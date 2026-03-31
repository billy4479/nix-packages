{
  fetchPypi,
  python3Packages,
  ...
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "standard_transform";
  version = "1.4.1";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-/VEO9XwYkn8tb8hjyUL0F5gdciEr+XxlP0yOhyoTexo=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    scipy
    numpy
    pandas
  ];
})
