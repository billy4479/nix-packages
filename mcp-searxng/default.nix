{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage rec {
  pname = "mcp-searxng";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "MCP-searxng";
    rev = "v${version}";
    hash = "sha256-M3VfUAxocp+Trj68WofTXwMAxBcD2j5bzb2mmNEPnAE=";
  };

  npmDepsHash = "sha256-8R1DJ4S/q6ZLxPMVcBKTE0lJre5KAssWTreG4yNKZFw=";

  meta = {
    description = "MCP server for SearXNG integration";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    license = lib.licenses.mit;
    mainProgram = "mcp-searxng";
  };
}
