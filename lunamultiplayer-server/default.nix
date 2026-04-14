{
  buildDotnetModule,
  fetchFromGitHub,

  dotnet-sdk_10,
  dotnet-runtime_10,
  ...
}:
let
  version = "0.29.1-Draft";

  src = fetchFromGitHub {
    repo = "LunaMultiplayer";
    owner = "LunaMultiplayer";
    rev = version;
    hash = "sha256-a8AWnSlx7h+ISpE/rbdUf2qapBCgbhTl4pfF/RaqVK8=";
  };
in
buildDotnetModule {
  pname = "lunamultiplayer-server";
  inherit version src;

  projectFile = [
    "Server/Server.csproj"
  ];
  executables = [ "Server" ];

  dotnet-sdk = dotnet-sdk_10;
  dotnet-runtime = dotnet-runtime_10;

  patches = [ ./change-working-dir.diff ];

  nugetDeps = ./deps.json;
}
