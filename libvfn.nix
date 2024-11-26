with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "libvfn development environment";

  nativeBuildInputs = [
    meson
    ninja
    perl
    pkg-config
    python3.pythonOnBuildForHost
    swig
    libnvme
    zsh
    sparse
    glibc
  ];

#  buildInputs = [
#    meson
#    ninja
#    perl
#    pkg-config
#    python3.pythonOnBuildForHost
#    swig
#    libnvme
#    zsh
#    sparse
#    glibc
#  ];

}
