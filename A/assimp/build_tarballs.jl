# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "assimp"
version = v"5.0.1"

# Collection of sources required to complete build
sources = [
    "https://github.com/assimp/assimp.git" =>
    "8f0c6b04b2257a520aaab38421b2e090204b69df",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd assimp/
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE="${CMAKE_TARGET_TOOLCHAIN}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DASSIMP_BUILD_ASSIMP_TOOLS=false \
    -DASSIMP_BUILD_TESTS=false \
    -DASSIMP_INSTALL_PDB=false \
    -DASSIMP_DOUBLE_PRECISION=false \

make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [p for p in supported_platforms() if p != Platform("i686", "linux"; libc="musl") &&
                                                 p != Platform("armv7l", "linux"; libc="musl")
            ]
platforms = expand_cxxstring_abis(platforms)

# The products that we will ensure are always built
products = [
    LibraryProduct("libassimp", :libassimp)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("Zlib_jll")
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies, preferred_gcc_version=v"7")
