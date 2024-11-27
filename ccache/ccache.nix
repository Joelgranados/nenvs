{ pkgs }:

{
  packageList = [
    pkgs.ccache
  ];

  shellHook = ''
    export PATH=${pkgs.ccache}/bin:$PATH; \
    export CC="ccache gcc"; \
    export CXX="ccache g++"; \
    alias make="make CC='"$CC"'"; \
    export CCACHE_DIR=/home/joel/.cache/.ccache; \
    mkdir -p $CCACHE_DIR; \
    echo "ccache configured with directory $CCACHE_DIR";
  '';
}

