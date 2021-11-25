{
  stdenv, lib, coreutils, clojure,
  makeWrapper, nix-prefetch-git,
  fetchMavenArtifact, fetchgit
}:

let cljdeps = import ./deps.nix { inherit fetchMavenArtifact fetchgit lib; };
    classp  = cljdeps.makeClasspaths {};
    version = "1.1.0-rc";

in stdenv.mkDerivation rec {

  name = "clj2nix-${version}";

  src = ./clj2nix.clj;

  buildInputs = [ makeWrapper ];

  phases = ["installPhase"];

  installPhase = ''

      mkdir -p $out/bin

      cp ${src} $out/bin
      makeWrapper ${clojure}/bin/clojure $out/bin/clj2nix \
        --add-flags "-Scp ${classp} -i ${src} -m clj2nix ${version}" \
        --prefix PATH : "$PATH:${lib.makeBinPath [ coreutils nix-prefetch-git ]}"
  '';
}
