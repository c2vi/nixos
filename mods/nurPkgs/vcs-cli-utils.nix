{ rustPlatform
, fetchFromGitHub
, lib
}:

rustPlatform.buildRustPackage rec {
	pname = "vcs-cli-utils";
	version = "0.3.2";

	src = fetchFromGitHub {
		owner = "henkelmax";
		repo = "svc-cli-utils";
    rev = "82e0af5b5e4cb0aa60bfeea4f9b1d3929fe4e1f8";
    sha256 = "sha256-ojuRqtUTNz/ZOuxx3ab1y9NknEfJNWPMXBf3kfIwfXM=";
	};

  cargoHash = "sha256-VvA7xlj7zcuHDNi4+TRSDheCchjpiK519OgNTJj2hPI=";

  meta = with lib; {
    description = "Command line utilities for the Simple Voice Chat Minecraft Mod";
    longDescription = ''
      Simple Voice Chat Mod: https://github.com/henkelmax/simple-voice-chat
    '';
    homepage = "https://github.com/henkelmax/svc-cli-utils";
    #maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "svc";
  };
}
