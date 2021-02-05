# llvm-toolchain
Collection of scripts used for building a complete, standalone Clang/LLVM-based toolchain. See: https://clang.llvm.org/docs/Toolchain.html

Requires CMake 3.16 or newer.

## Usage

```bash
git clone https://github.com/jvstech/llvm-toolchain.git .
cmake -P llvm-toolchain/build-llvm-toolchain.cmake
```

Clang, LLD, LLVM, and their associated runtimes will be installed to `./install/`.
