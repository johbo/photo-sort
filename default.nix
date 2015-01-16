with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "photo-sort";

  src = "./.";

  buildInputs = [
    # TODO: Provide D tools
    # dub
    # dmd
    freeimage
  ];

  propagatedBuildInputs = [];

  buildPhase = ''
  '';

  installPhase = ''
  '';

}

