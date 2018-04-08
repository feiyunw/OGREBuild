@echo off
setlocal ENABLEEXTENSIONS

:: Install software in disk D: 7-Zip, android-studio, sdk-tools-windows, Cg, CMake, DirectX SDK (June 2010), Doxygen, Graphviz, JDK, Strawberry Perl, Python 2.x (amd64), Visual Studio 2017, WiX Toolset
:: [Numpy](https://pypi.python.org/pypi/numpy): python -m pip install --user numpy
:: [Text::Template]: cpan -i Text::Template
:: [Test::More]: cpan -i Test::More
:: Run this batch file from "x64 Native Tools Command Prompt for VS 2017", or
:: call "D:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
set CMAKE="D:\Program Files\CMake\bin\cmake.exe"
set JAVA_HOME=D:\Program Files\Java\jdk-10.0.1
set PYTHON=D:\Python27\python.exe
set PYTHONPATH=D:\Python27\Lib;D:\Python27\Lib\site-packages
set DirectX9_D3DX9_LIBRARY="D:\Program Files (x86)\Microsoft DirectX SDK (June 2010)\Lib\x64\d3dx9.lib"
set EGLINC="D:\android\sdk-tools-windows\ndk-bundle\sysroot\usr\include\EGL"
set EGL_egl_LIBRARY="D:\android\sdk-tools-windows\ndk-bundle\platforms\android-24\arch-arm64\usr\lib\libEGL.so"
set GLES2INC="D:\android\sdk-tools-windows\ndk-bundle\sysroot\usr\include\GLES2"
set OPENGLES2_gl_LIBRARY="D:\android\sdk-tools-windows\ndk-bundle\platforms\android-24\arch-arm64\usr\lib\libGLESv2.so"
set GLES3INC="D:\android\sdk-tools-windows\ndk-bundle\sysroot\usr\include\GLES3"
set OPENGLES3_gl_LIBRARY="D:\android\sdk-tools-windows\ndk-bundle\platforms\android-24\arch-arm64\usr\lib\libGLESv3.so"
set GRAPHVIZDOT="D:\Program Files (x86)\Graphviz2.38\bin\dot.exe"
set Java_JAVAH_EXECUTABLE="D:\android\android-studio\jre\bin\javah.exe"
set WIXBIN="C:\Program Files (x86)\WiX Toolset v3.11\bin"

set CLASSPATH=.;%JAVA_HOME%\lib;%JAVA_HOME%\lib\tools.jar
set BUILDDIR=%~dp0build\
set OGRE_HOME=%~dp0ogre\
set OGRE_DEPENDENCIES_DIR=%~dp0Dependencies\
set DEPBIN=%OGRE_DEPENDENCIES_DIR%bin\
set DEPLIB=%OGRE_DEPENDENCIES_DIR%lib\
set DEPINC=%OGRE_DEPENDENCIES_DIR%include\
set DEPSRC=%OGRE_DEPENDENCIES_DIR%src\
set BOOST_ROOT=%DEPSRC%boost\
set BOOST_INCLUDEDIR=%DEPINC%
set BOOST_LIBRARYDIR=%DEPLIB%
set PATH=%PATH%;%DEPBIN%;%DEPLIB%;%DEPSRC%swigwin
set MSBUILD=MSBuild.exe /m /p:Configuration=Release;Platform=x64;PlatformToolset=v141;WindowsTargetPlatformVersion=%UCRTVersion%;CharacterSet=MultiByte
set MSBUILDDBG=MSBuild.exe /m /p:Configuration=Debug;Platform=x64;PlatformToolset=v141;WindowsTargetPlatformVersion=%UCRTVersion%;CharacterSet=MultiByte
set MSBUILD32=MSBuild.exe /m /p:Configuration=Release;Platform=Win32;PlatformToolset=v141;WindowsTargetPlatformVersion=%UCRTVersion%;CharacterSet=MultiByte
set MSBUILD32DBG=MSBuild.exe /m /p:Configuration=Debug;Platform=Win32;PlatformToolset=v141;WindowsTargetPlatformVersion=%UCRTVersion%;CharacterSet=MultiByte
mkdir %BUILDDIR% 1>NUL 2>&1
mkdir %DEPBIN% 1>NUL 2>&1
mkdir %DEPBIN%Debug 1>NUL 2>&1
mkdir %DEPBIN%Release 1>NUL 2>&1
mkdir %DEPLIB% 1>NUL 2>&1
mkdir %DEPINC% 1>NUL 2>&1

:zlib
echo ===== Building zlib
cd /d %DEPSRC%zlib
cd
nmake /f %DEPSRC%zlib\win32\Makefile.msc
copy /Y %DEPSRC%zlib\*.dll %DEPBIN%
copy /Y %DEPSRC%zlib\*.lib %DEPLIB%
copy /Y %DEPSRC%zlib\zconf.h %DEPINC%
copy /Y %DEPSRC%zlib\zlib.h %DEPINC%

:zzip
echo ===== Building zziplib
%MSBUILDDBG% %DEPSRC%zziplib\vs2017\zziplib.sln /t:Rebuild
%MSBUILD% %DEPSRC%zziplib\vs2017\zziplib.sln /t:Rebuild
copy /Y %DEPSRC%zziplib\vs2017\x64\Debug\*.exe %DEPBIN%
copy /Y %DEPSRC%zziplib\vs2017\x64\Debug\*.dll %DEPBIN%
copy /Y %DEPSRC%zziplib\vs2017\x64\Debug\*.lib %DEPLIB%
copy /Y %DEPSRC%zziplib\vs2017\x64\Release\*.exe %DEPBIN%
copy /Y %DEPSRC%zziplib\vs2017\x64\Release\*.dll %DEPBIN%
copy /Y %DEPSRC%zziplib\vs2017\x64\Release\*.lib %DEPLIB%
xcopy %DEPSRC%zziplib\zzip\*.h %DEPINC%zzip\ /Y

echo ===== Building FreeImage Dependencies
:: LibJPEG
xcopy %DEPSRC%jpeg %DEPSRC%FreeImage\Source\LibJPEG /S /Y
echo ===== Building LibJPEG
cd /d %DEPSRC%FreeImage\Source\LibJPEG
cd
nmake /f %DEPSRC%FreeImage\Source\LibJPEG\makefile.vs setup-v15
::%MSBUILD% %DEPSRC%FreeImage\Source\LibJPEG\LibJPEG.2013.vcxproj /t:Rebuild

:: ZLib
xcopy %DEPSRC%zlib %DEPSRC%FreeImage\Source\ZLib /S /Y
::%MSBUILD% %DEPSRC%FreeImage\Source\ZLib\ZLib.2013.vcxproj /t:Rebuild

:: LibPNG
xcopy %DEPSRC%libpng %DEPSRC%FreeImage\Source\LibPNG /S /Y
copy /Y %DEPSRC%FreeImage\Source\LibPNG\scripts\pnglibconf.h.prebuilt %DEPSRC%FreeImage\Source\LibPNG\pnglibconf.h
::%MSBUILD% %DEPSRC%FreeImage\Source\LibPNG\LibPNG.2013.vcxproj /t:Rebuild

:: OpenEXR
:: TODO: fix LNK2001 IlmThread when linking freeimage
:: TODO: fix C4819 codepage(936) warning
echo ===== Building IlmBase
set INSTALLDIR=%OGRE_DEPENDENCIES_DIR%
mkdir %BUILDDIR%openexr\IlmBase 1>NUL 2>&1
cd /d %BUILDDIR%openexr\IlmBase
cd
del /f CMakeCache.txt 1>NUL 2>&1
%CMAKE% -DCMAKE_INSTALL_PREFIX=%INSTALLDIR% -DNAMESPACE_VERSIONING=OFF -G"Visual Studio 15 2017 Win64" %DEPSRC%openexr\IlmBase
%MSBUILD% %BUILDDIR%openexr\IlmBase\INSTALL.vcxproj /t:Rebuild
echo ===== Building OpenEXR
mkdir %BUILDDIR%openexr\OpenEXR 1>NUL 2>&1
cd /d %BUILDDIR%openexr\OpenEXR
cd
del /f CMakeCache.txt 1>NUL 2>&1
%CMAKE% -DZLIB_ROOT=%DEPSRC%zlib -DILMBASE_PACKAGE_PREFIX=%INSTALLDIR% -DCMAKE_INSTALL_PREFIX=%INSTALLDIR% -DNAMESPACE_VERSIONING=OFF -G"Visual Studio 15 2017 Win64" %DEPSRC%openexr\OpenEXR
%MSBUILD% %BUILDDIR%openexr\OpenEXR\INSTALL.vcxproj /t:Rebuild

:: LibOpenJPEG
:: TODO: use latest source
::xcopy %DEPSRC%openjpeg\src\lib\openjp2 %DEPSRC%FreeImage\Source\LibOpenJPEG /S /Y
::%MSBUILD% %DEPSRC%FreeImage\Source\LibOpenJPEG\LibOpenJPEG.2013.vcxproj /t:Rebuild

:: LibRawLite
:: TODO: fix C4819 codepage(936) warning
xcopy %DEPSRC%LibRaw %DEPSRC%FreeImage\Source\LibRawLite /S /Y
::%MSBUILD% %DEPSRC%FreeImage\Source\LibRawLite\LibRawLite.2013.vcxproj /t:Rebuild

:: LibTIFF4
:: TODO: fix LNK2001 _TIFFcalloc unix/win32 problem
::xcopy %DEPSRC%tiff\libtiff %DEPSRC%FreeImage\Source\LibTIFF4 /S /Y
copy /Y %DEPSRC%FreeImage\Source\LibTIFF4\tif_config.vc.h %DEPSRC%FreeImage\Source\LibTIFF4\tif_config.h
copy /Y %DEPSRC%FreeImage\Source\LibTIFF4\tiffconf.vc.h %DEPSRC%FreeImage\Source\LibTIFF4\tiffconf.h
::%MSBUILD% %DEPSRC%FreeImage\Source\LibTIFF4\LibTIFF4.2013.vcxproj /t:Rebuild

:: LibWebP
:: TODO: use latest source
::xcopy %DEPSRC%libwebp\src %DEPSRC%FreeImage\Source\LibWebP\src /S /Y
::%MSBUILD% %DEPSRC%FreeImage\Source\LibWebP\LibWebP.2013.vcxproj /t:Rebuild

:: LibJXR
:: TODO: use latest source
:: TODO: fix C4819 codepage(936) warning
::%MSBUILD% %DEPSRC%FreeImage\Source\LibJXR\LibJXR.2013.vcxproj /t:Rebuild

:freeimage
:: TODO: fix C4819 codepage(936) warning
echo ===== Building FreeImage
%MSBUILD% %DEPSRC%FreeImage\FreeImage.2013.sln /t:Rebuild
copy /Y %DEPSRC%FreeImage\x64\Release\*.dll %DEPBIN%
copy /Y %DEPSRC%FreeImage\x64\Release\*.lib %DEPLIB%
copy /Y %DEPSRC%FreeImage\Source\FreeImage.h %DEPINC%
copy /Y %DEPLIB%*.dll %DEPBIN%

:freetype2
:: TODO: fix C4819 codepage(936) warning
echo ===== Building freetype2
%MSBUILD% %DEPSRC%freetype2\builds\windows\vc2010\freetype.sln /t:Rebuild
copy /Y %DEPSRC%freetype2\objs\x64\Release\*.dll %DEPBIN%
copy /Y %DEPSRC%freetype2\objs\x64\Release\*.lib %DEPLIB%
xcopy %DEPSRC%freetype2\include %DEPINC% /S /Y

:icu4c
:: TODO: fix U1077 genbrk.EXE returned 0x10002
echo ===== Building icu4c
%MSBUILD% %DEPSRC%icu4c\source\allinone\allinone.sln /t:Clean
%MSBUILDDBG% %DEPSRC%icu4c\source\allinone\allinone.sln /t:Clean
%MSBUILD% %DEPSRC%icu4c\source\allinone\allinone.sln /t:testplug;ctestfw;io
%MSBUILDDBG% %DEPSRC%icu4c\source\allinone\allinone.sln /t:testplug;ctestfw;io
:: testplug(testplug)->toolutil(icutu)->common(icuuc)->stubdata
:: ctestfw(icutest)->toolutil(icutu)->common(icuuc)->stubdata
:: io(icuio)->i18n(icuin)->common(icuuc)->stubdata
:: makedata(icudt)->ctestfw, io
copy /Y %DEPSRC%icu4c\bin64\*.dll %DEPBIN%
copy /Y %DEPSRC%icu4c\lib64\*.lib %DEPLIB%
xcopy %DEPSRC%icu4c\include %DEPINC% /S /Y

:bzip2
echo ===== Building bzip2
cd /d %DEPSRC%bzip2
cd
nmake /f %DEPSRC%bzip2\makefile.msc
copy /Y %DEPSRC%bzip2\libbz2.lib %DEPLIB%\bz2.lib
copy /Y %DEPSRC%bzip2\bzlib.h %DEPINC%

:lzma
echo ===== Building lzma
%MSBUILD% %DEPSRC%xz\windows\vs2017\xz_win.sln /t:Rebuild
copy /Y %DEPSRC%xz\windows\vs2017\Release\x64\liblzma_dll\*.dll %DEPBIN%
copy /Y %DEPSRC%xz\windows\vs2017\Release\x64\liblzma_dll\liblzma.lib %DEPLIB%\lzma.lib
xcopy %DEPSRC%xz\src\liblzma\api\*.h %DEPINC% /S /Y

:boost
:: TODO: warning: Graph library does not contain MPI-based parallel components. note: to enable them, add "using mpi ;" to your user-config.jam
echo ===== Building boost
cd /d %DEPSRC%boost
cd
call %DEPSRC%boost\bootstrap.bat vc141
set INSTALLDIR=%OGRE_DEPENDENCIES_DIR%
b2.exe --prefix=%INSTALLDIR% --build-dir=%BUILDDIR% --layout=tagged -a -d+2 -q -j6 --reconfigure --debug-configuration -sICU_PATH=%DEPSRC%icu4c toolset=msvc-14.1 address-model=64 variant=release link=shared threading=multi runtime-link=shared include=%DEPINC% library-path=%DEPLIB% dll-path=%DEPBIN% cxxflags=/utf-8 optimization=space install

:Cg
echo ===== Handling Cg
xcopy %DEPSRC%Cg\bin.x64 %DEPBIN% /S /Y
xcopy %DEPSRC%Cg\lib.x64 %DEPLIB% /S /Y
xcopy %DEPSRC%Cg\include %DEPINC% /S /Y
copy /Y %DEPBIN%cg.dll %DEPBIN%\Debug\Cg.dll
copy /Y %DEPBIN%cg.dll %DEPBIN%\Release\Cg.dll

:openssl
echo ===== Building openssl
mkdir %BUILDDIR%openssl 1>NUL 2>&1
cd /d %BUILDDIR%openssl
cd
set INSTALLDIR=%OGRE_DEPENDENCIES_DIR%
perl %DEPSRC%openssl\Configure threads shared zlib-dynamic no-asm --prefix=%INSTALLDIR% --openssldir=%INSTALLDIR% --with-zlib-include=%DEPINC% --with-zlib-lib=%DEPBIN%\zlib1.dll no-deprecated no-tests VC-WIN64A
nmake install_sw

:poco
setlocal ENABLEEXTENSIONS
echo ===== Building POCO
cd /d %DEPSRC%poco
cd
set INCLUDE=%INCLUDE%;%DEPSRC%poco\openssl\VS_120\include;%DEPSRC%mysql\include
set LIB=%LIB%;%DEPSRC%poco\openssl\VS_120\win64\lib\release;%DEPSRC%mysql\lib
call %DEPSRC%poco\buildwin 150 rebuild shared release x64 nosamples notests msbuild
xcopy %DEPSRC%poco\bin64\*.dll %DEPBIN% /S /Y
xcopy %DEPSRC%poco\lib64\*.lib %DEPLIB% /S /Y
FOR /D %%X IN (CppParser Crypto Data\MySQL Data\ODBC Data\SQLite Data Encodings Foundation JSON MongoDB Net NetSSL_OpenSSL NetSSL_Win PDF Redis SevenZip Util XML Zip) DO (
	xcopy %DEPSRC%poco\%%X\include\Poco\*.h %DEPINC%\Poco\ /S /Y
)
endlocal

:tbb
echo ===== Building TBB
%MSBUILD% /p:Configuration=Release-MT %DEPSRC%tbb\build\vs2013\makefile.sln /t:Rebuild 
xcopy %DEPSRC%tbb\build\vs2013\x64\Release-MT\*.dll %DEPBIN% /Y
xcopy %DEPSRC%tbb\build\vs2013\x64\Release-MT\*.lib %DEPLIB% /Y
xcopy %DEPSRC%tbb\include\tbb %DEPINC%tbb\ /S /Y
xcopy %DEPSRC%tbb\include\serial\tbb %DEPINC%tbb\ /S /Y

:glsl-optimizer
echo ===== Building GLSL_Optimizer
%MSBUILD% %DEPSRC%glsl-optimizer\projects\vs2010\glsl_optimizer.sln /t:Rebuild
copy /Y %DEPSRC%glsl-optimizer\src\glsl\glsl_optimizer.h %DEPINC%
copy /Y %DEPSRC%glsl-optimizer\projects\vs2010\build\glsl_optimizer_lib\x64\Release\glsl_optimizer_lib-x64.lib %DEPLIB%\glsl_optimizer.lib

:hlsl2glsl
echo ===== Building HLSL2GLSL
%MSBUILD% %DEPSRC%hlsl2glslfork\hlslang.vcxproj /t:Rebuild
copy /Y %DEPSRC%hlsl2glslfork\lib\win64\Release\*.lib %DEPLIB%
copy /Y %DEPSRC%hlsl2glslfork\include\*.h %DEPINC%

:SDL2
echo ===== Building SDL2
%MSBUILD% %DEPSRC%SDL2\VisualC\SDL.sln /t:Rebuild
copy /Y %DEPSRC%SDL2\VisualC\x64\Release\*.dll %DEPBIN%
copy /Y %DEPSRC%SDL2\VisualC\x64\Release\*.lib %DEPLIB%
xcopy %DEPSRC%SDL2\include\*.h %DEPINC%\SDL2\ /S /Y

:ogre
:: TODO: fix OGRE_BUILD_COMPONENT_JAVA, OGRE_BUILD_COMPONENT_PYTHON
echo ===== Preparing OGRE
set INSTALLDIR=%~dp0install\ogre
set SWIG_EXECUTABLE=%DEPSRC%swigwin\swig.exe
mkdir %INSTALLDIR% 1>NUL 2>&1
mkdir %BUILDDIR%ogre 1>NUL 2>&1
cd /d %BUILDDIR%ogre
cd
del /f CMakeCache.txt 1>NUL 2>&1
%CMAKE% -G"Visual Studio 15 2017 Win64" -Tv141 -Wno-dev -DCMAKE_INSTALL_PREFIX=%INSTALLDIR% -DCMAKE_BUILD_TYPE="MinSizeRel" -DOGRE_BUILD_COMPONENT_JAVA:BOOL=FALSE -DOGRE_BUILD_COMPONENT_PYTHON:BOOL=FALSE -DOGRE_BUILD_DEPENDENCIES:BOOL=FALSE -DOGRE_CONFIG_THREADS=3 -DOGRE_DEPENDENCIES_DIR:PATH=%OGRE_DEPENDENCIES_DIR% -DDirectX9_D3DX9_LIBRARY:PATH=%DirectX9_D3DX9_LIBRARY% -DSWIG_EXECUTABLE:PATH=%SWIG_EXECUTABLE% -DDOXYGEN_DOT_EXECUTABLE:PATH=%GRAPHVIZDOT% -DEGL_INCLUDE_DIR:PATH=%EGLINC% -DEGL_egl_LIBRARY:PATH=%EGL_egl_LIBRARY% -DJava_JAVAH_EXECUTABLE:PATH=%Java_JAVAH_EXECUTABLE% -DOPENGLES2_INCLUDE_DIR:PATH=%GLES2INC% -DOPENGLES2_gl_LIBRARY:PATH=%OPENGLES2_gl_LIBRARY% -DOPENGLES3_INCLUDE_DIR:PATH=%GLES3INC% -DOPENGLES3_gl_LIBRARY:PATH=%OPENGLES3_gl_LIBRARY% -DWix_BINARY_DIR:PATH=%WIXBIN% %~dp0ogre
echo ===== Building OGRE
MSBuild.exe /m /p:Configuration=MinSizeRel;Platform=x64;PlatformToolset=v141;WindowsTargetPlatformVersion=%UCRTVersion%;CharacterSet=MultiByte %BUILDDIR%ogre\INSTALL.vcxproj /t:Rebuild

:bye
endlocal

