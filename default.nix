with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "photo-sort";

  src = "./.";

  buildInputs = [
    dmd
    # TODO: Not yet available in nixpkgs
    # dub
    freeimage
  ];

  propagatedBuildInputs = [];

  buildPhase = ''
  '';

  installPhase = ''
  '';

}

