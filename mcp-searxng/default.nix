{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage rec {
  pname = "mcp-searxng";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "MCP-searxng";
    rev = "v${version}";
    hash = "sha256-LMlbuPF8KuUZlD9HUjhunuHl2tmCMSeydBZiWuGWRHA=";
  };

  npmDepsHash = "sha256-MqVn66vCbB8+3o6KB6GCU9GxsPtqeCYjTbI5A3nfTVs=";

  meta = {
    description = "MCP server for SearXNG integration";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    license = lib.licenses.mit;
    mainProgram = "mcp-searxng";
  };
}
