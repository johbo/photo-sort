with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "photo-sort";

  src = ./.;

  buildInputs = [
    dmd
    dub
    freeimage
  ];

  propagatedBuildInputs = [];

  buildPhase = ''
    # TODO: Find a solution to avoid the HOME tweak here
    # Tried --cache=local, but this did explode
    echo `pwd`
    HOME=`pwd` dub build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp photo-sort $out/bin
  '';

}

