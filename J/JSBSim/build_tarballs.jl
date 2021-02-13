using BinaryBuilder

name = "JSBSim"
version = v"1.1.6"

# Collection of sources required to build JSBSim
sources = [
    GitSource("https://github.com/bcoconni/jsbsim.git", "a31ecb8727361aa74dee4ea7158c944848f78fb6"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/jsbsim
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} -DCMAKE_BUILD_TYPE=Release -DBUILD_DOCS=OFF -DBUILD_PYTHON_MODULE=OFF ..
make -j${nproc}
cp julia/*JSBSimJL* $prefix/.
cp ../julia/JSBSim.jl $prefix/.
"""

# Skip platforms with GCC 4.x because it does not support C++14
platforms = [p for p in supported_platforms() if compiler_abi(p).gcc_version != :gcc4]

# The products that we will ensure are always built
products = [
    FileProduct("JSBSim.jl", :JSBSim),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("libcxxwrap_julia_jll"),
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

