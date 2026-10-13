{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage rec {
  pname = "mcp-searxng";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "MCP-searxng";
    rev = "v${version}";
    hash = "sha256-TqDj86FTOekTswNQkTkiC8Q/H46bz4iigr5GRlM9Tno=";
  };

  npmDepsHash = "sha256-WuN8xzG5uU1wZdMLdiT2GfUn1BeHTdtIkBc4x2kz81Q=";

  meta = {
    description = "MCP server for SearXNG integration";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    license = lib.licenses.mit;
    mainProgram = "mcp-searxng";
  };
}
