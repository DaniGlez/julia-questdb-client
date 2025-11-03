using BinaryBuilder
using BinaryBuilderBase

name = "c_questdb_client"
version = v"5.1.0"

sources = [
    GitSource("https://github.com/questdb/c-questdb-client", "b3f08faafd10bf555d873080a8ac4604a807c011")
]


# Bash recipe for building across all platforms
script = raw"""
cd ${WORKSPACE}/srcdir/c-questdb-client/questdb-rs-ffi
cargo build --release
if [[ "${target}" == *-w64-mingw32* ]]; then    
    install -D -m 755 "target/${rust_target}/release/questdb_client.${dlext}" "${libdir}/c_questdb_client.${dlext}"
else
    install -D -m 755 "target/${rust_target}/release/libquestdb_client.${dlext}" "${libdir}/c_questdb_client.${dlext}"
fi

install -D -m 755 "${WORKSPACE}/srcdir/c-questdb-client/include/questdb/ingress/line_sender.h" "${includedir}/line_sender.h"


"""
#only macos
platforms = supported_platforms(exclude=Sys.islinux)
# Our Rust toolchain for i686 Windows is unusable
filter!(p -> !Sys.iswindows(p) || arch(p) != "i686", platforms)

# The products that we will ensure are always built
products = [
    LibraryProduct("c_questdb_client", :c_questdb_client)
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6", compilers=[:c, :rust])