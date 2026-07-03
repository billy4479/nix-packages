{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage rec {
  pname = "mcp-searxng";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "MCP-searxng";
    rev = "v${version}";
    hash = "sha256-bSEn9BGYM85gcd1INBpIXPbpG2gbOx8cG8q8qUQwCrA=";
  };

  npmDepsHash = "sha256-KgfrMCBRv0DQUYIrwCbB5ecZn/DR39N/qbYWtYPzuAA=";

  meta = {
    description = "MCP server for SearXNG integration";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    license = lib.licenses.mit;
    mainProgram = "mcp-searxng";
  };
}
