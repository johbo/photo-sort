with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "photo-sort";

  src = "./.";

  buildInputs = [
    # dub
    # dmd
    libexif
    freeimage
  ];

  propagatedBuildInputs = [];

  buildPhase = ''
  '';

  installPhase = ''
  '';

}

