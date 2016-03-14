call "%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86

rmdir /S /Q Release
mkdir Release\Build
cd Release\Build

cmake -DPRODUCTION_MODE:BOOL=TRUE ..\..\Sources -G "CodeBlocks - NMake Makefiles"
nmake
cpack

move *.zip ..

cd ../..