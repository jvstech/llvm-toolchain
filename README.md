# llvm-toolchain
Collection of scripts used for building a complete, standalone Clang/LLVM-based toolchain. See: https://clang.llvm.org/docs/Toolchain.html

Requires CMake 3.16 or newer.

## Usage

```bash
git clone https://github.com/jvstech/llvm-toolchain.git .
cmake -P build-llvm-toolchain.cmake
```

Clang, LLD, LLVM, and their associated runtimes will be installed to `./install/`.

### Cross-building for Windows

To build a Windows LLVM toolchain from your non-Windows build system, you must first have headers and libraries from [Visual Studio](https://visualstudio.microsoft.com/downloads/) and the [Windows SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/). You will need to copy the following directories to a location accessible by your build system:

- Visual C++ base -- contains the C++ STL used by Visual Studio, usually found at `${env:ProgramFiles(x86)}\Microsoft Visual Studio\<vs-version>\Professional\VC\Tools\MSVC\<some-version-number>`. You'll only need the `include` and `lib` directories as well as the `atlmfc` directory if it exists. 
- Windows SDK base -- contains the native Windows headers and system libraries used by the Universal CRT, usually found at `${env:ProgramFiles(x86)}\Windows Kits\<windows-version>`. You'll only need the `Include` and `Lib` directories, and you can further streamline by only using a single version folder from each of these (such as `10.0.19041.0` for example). The rest of the version folders aren't required.

The build scripts make use of the [WinMsvc.cmake](https://github.com/llvm/llvm-project/blob/main/llvm/cmake/platforms/WinMsvc.cmake) toolchain script from the LLVM source in order to build for Windows. As such, some of the CMake variables used by this toolchain script also need to be specified when running `build-llvm-toolchain.cmake`:

- `LLVM_WINSYSROOT` -- a directory containing both the Visual C++ base and the Windows SDK base. The following directories are expected to exist:
  - `${LLVM_WINSYSROOT}/VC/Tools/MSVC/<msvc-version-number>`
  - `${LLVM_WINSYSROOT}/Windows Kits/10/Include/<winsdk-version-number>`
  - `${LLVM_WINSYSROOT}/Windows Kits/10/Lib/<winsdk-version-number>`
- `MSVC_VER` (optional, defaults to highest found) -- name of the version folder of the Visual C++ base
- `WINSDK_VER` (optional, defaults to highest found) -- name of the version folder from the Windows SDK to use
- `HOST_ARCH` (optional, defaults to `x86_64`) -- host architecture for which to build (aarch64, arm64, armv7, arm, i686, x86, x86_64/x64)

Finally, you must set `CMAKE_SYSTEM_NAME` to "Windows".

```bash
# Example usage for building for Windows
git clone https://github.com/jvstech/llvm-toolchain.git .
cmake \
  -DCMAKE_SYSTEM_NAME=Windows \
  -DLLVM_WINSYSROOT=/home/user/projects/windows_sysroot \
  -P build-llvm-toolchain.cmake
```
