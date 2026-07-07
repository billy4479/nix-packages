{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage rec {
  pname = "mcp-searxng";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "MCP-searxng";
    rev = "v${version}";
    hash = "sha256-xiIYkzWlff9RdoYyEWqYB85RLkZjACumGaCsw3WgN+Q=";
  };

  npmDepsHash = "sha256-aebwhDKEo383P3ylKGQQQ1+3l8O0jYMBBBtZBt0dQOY=";

  meta = {
    description = "MCP server for SearXNG integration";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    license = lib.licenses.mit;
    mainProgram = "mcp-searxng";
  };
}
