{ stdenv }:

stdenv.mkDerivation {
  pname = "doom-emacs";
  version = "git-20200224";

  src = ./doom-emacs; # submodule :)

  outputs = [ "out" "bin" ];

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/share/doom-emacs
    cp -r $src/* $out/share/doom-emacs

    mkdir -p $bin/bin
    ln -s $src/bin/doom $bin/bin/doom
  '';
}
