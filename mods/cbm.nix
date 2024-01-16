{ stdenv
, fetchFromGitHub
, ncurses
, autoreconfHook
}:

stdenv.mkDerivation rec {
	pname = "cbm";
	version = "0.3.2";

	src = fetchFromGitHub {
		owner = "resurrecting-open-source-projects";
		repo = "cbm";
    rev = "master";
    sha256 = "sha256-Ubm8jky8nbJZWVSlqipg22ZjlnsgdVmoQWxYi9cyags=";
	};

	nativeBuildInputs = [
		ncurses
    autoreconfHook
	];
}
