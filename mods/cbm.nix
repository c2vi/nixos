{ stdenv
, fetchFromGitHub
, libncurses
}:

stdenv.mkDerivation rec {
	pname = "cbm";
	version = "0.3.2";

	src = fetchFromGitHub {
		owner = "resurrecting-open-source-projects";
		repo = "cbm";
		tag = version;
	};

	nativeBuildInputs = [
		libncurses
	];
}
