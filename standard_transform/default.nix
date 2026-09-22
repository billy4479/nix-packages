{
  fetchPypi,
  python3Packages,
  ...
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "standard_transform";
  version = "2.0.0";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-isA3uXMRqaGURVnvoRoYjLqW0A5ILAMLB9fn7+vPhlI=";
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
