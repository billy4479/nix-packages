{
  buildDotnetModule,
  fetchFromGitHub,

  dotnet-sdk_10,
  dotnet-runtime_10,
  ...
}:
let
  version = "0.29.2";

  src = fetchFromGitHub {
    repo = "LunaMultiplayer";
    owner = "LunaMultiplayer";
    rev = version;
    hash = "sha256-50x2d1xZRJFHA02D2U121IhRm5RH2cVZManRYAFHeTY=";
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

  postPatch = ''
    substituteInPlace global.json \
      --replace-fail '"version": "6.0.403"' '"version": "${dotnet-sdk_10.version}"'
    substituteInPlace \
      Lidgren.Core/Lidgren.Core.csproj \
      LmpMasterServer/LmpMasterServer.csproj \
      LmpMasterServerTest/LmpMasterServerTest.csproj \
      MasterServer/MasterServer.csproj \
      Server/Server.csproj \
      ServerTest/ServerTest.csproj \
      --replace-fail "<TargetFramework>net6.0</TargetFramework>" "<TargetFramework>net10.0</TargetFramework>"
  '';

  nugetDeps = ./deps.json;
}
