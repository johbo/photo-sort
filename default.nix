with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "photo-sort";

  src = "./.";

  buildInputs = [
    # dub
    # dmd
    libexif
  ];

  propagatedBuildInputs = [];

  buildPhase = ''
  '';

  installPhase = ''
  '';

}

