@echo off
setlocal ENABLEEXTENSIONS
set DP0=%~dp0
cd /d %DP0%

:: Install software in disk D: 7-Zip, android-studio, sdk-tools-windows, Cg, CMake, DirectX SDK (June 2010), Doxygen, Graphviz, JDK, Strawberry Perl, Python 2.x and 3.x (amd64), Visual Studio 2017 (with Windows SDK 8.1), WiX Toolset
:: [Numpy](https://pypi.python.org/pypi/numpy): python -m pip install --upgrade numpy
:: [Text::Template]: cpan -i Text::Template
:: [Test::More]: cpan -i Test::More
:: Run this batch file from "x64 Native Tools Command Prompt for VS 2017", or
:: call "D:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
set CMAKE="D:\Program Files\CMake\bin\cmake.exe"
set JAVA_HOME=D:\Program Files\Java\jdk-12
set DirectX9_D3DX9_LIBRARY="D:\Program Files (x86)\Microsoft DirectX SDK (June 2010)\Lib\x64\d3dx9.lib"
set EGLINC="D:\android\sdk-tools-windows\ndk-bundle\sysroot\usr\include\EGL"
set EGL_egl_LIBRARY="D:\android\sdk-tools-windows\ndk-bundle\platforms\android-28\arch-arm64\usr\lib\libEGL.so"
set GLES2INC="D:\android\sdk-tools-windows\ndk-bundle\sysroot\usr\include\GLES2"
set OPENGLES2_gl_LIBRARY="D:\android\sdk-tools-windows\ndk-bundle\platforms\android-28\arch-arm64\usr\lib\libGLESv2.so"
set GRAPHVIZDOT="D:\Program Files (x86)\Graphviz2.38\bin\dot.exe"
set Java_JAVAH_EXECUTABLE="D:\android\android-studio\jre\bin\javah.exe"
set WIXBIN="C:\Program Files (x86)\WiX Toolset v3.11\bin"

set BUILDDIR=%DP0%build\
set OGRE_HOME=%DP0%ogre\
set OGRE_DEPENDENCIES_DIR=%DP0%Dependencies\
set DEPBIN=%OGRE_DEPENDENCIES_DIR%bin\
set DEPLIB=%OGRE_DEPENDENCIES_DIR%lib\
set DEPINC=%OGRE_DEPENDENCIES_DIR%include\
set DEPSRC=%OGRE_DEPENDENCIES_DIR%src\
set PATH=%PATH%;%DEPBIN%;%DEPLIB%;%DEPSRC%swigwin
set MSBUILD=MSBuild.exe /m /p:Configuration=Release;Platform=x64;PlatformToolset=v141;WindowsTargetPlatformVersion=%UCRTVersion%;CharacterSet=MultiByte
set MSBUILDDBG=MSBuild.exe /m /p:Configuration=Debug;Platform=x64;PlatformToolset=v141;WindowsTargetPlatformVersion=%UCRTVersion%;CharacterSet=MultiByte
set MSBUILD32=MSBuild.exe /m /p:Configuration=Release;Platform=Win32;PlatformToolset=v141;WindowsTargetPlatformVersion=%UCRTVersion%;CharacterSet=MultiByte
set MSBUILD32DBG=MSBuild.exe /m /p:Configuration=Debug;Platform=Win32;PlatformToolset=v141;WindowsTargetPlatformVersion=%UCRTVersion%;CharacterSet=MultiByte
mkdir %BUILDDIR% 1>NUL 2>&1
mkdir %DEPBIN% 1>NUL 2>&1
mkdir %DEPLIB% 1>NUL 2>&1
mkdir %DEPINC% 1>NUL 2>&1

if "%VSCMD_ARG_TGT_ARCH%" NEQ "x64" (
	echo Run this script in a Visual Studio "x64 Native Tools Command Prompt for VS" window.
	goto bye
)

where py
if ERRORLEVEL 1 (
	echo Unable to find Python 3. ICU versions 64 and later will require Python 3 to build.
	echo See ICU-10923 for more information: https://unicode-org.atlassian.net/browse/ICU-10923
	goto bye
)

where perl
if ERRORLEVEL 1 (
	echo Unable to find Perl. OpenSSL will require Perl to build.
	goto bye
)

:zlib
echo ===== Building zlib
cd /d %DEPSRC%zlib
cd
nmake /f %DEPSRC%zlib\win32\Makefile.msc AS=ml64 LOC="-DASMV -DASMINF -I." OBJA="inffasx64.obj gvmat64.obj inffas8664.obj"
copy /Y %DEPSRC%zlib\*.dll %DEPBIN%
copy /Y %DEPSRC%zlib\*.lib %DEPLIB%
copy /Y %DEPSRC%zlib\zconf.h %DEPINC%
copy /Y %DEPSRC%zlib\zlib.h %DEPINC%

:zzip
echo ===== Building zziplib
%MSBUILD% %DEPSRC%zziplib\vs2017\zziplib.sln /t:Rebuild
copy /Y %DEPSRC%zziplib\vs2017\x64\Release\*.exe %DEPBIN%
copy /Y %DEPSRC%zziplib\vs2017\x64\Release\*.dll %DEPBIN%
copy /Y %DEPSRC%zziplib\vs2017\x64\Release\*.lib %DEPLIB%
xcopy %DEPSRC%zziplib\zzip\*.h %DEPINC%zzip\ /Y

:freeimage
:: TODO: fix C4819 codepage(936) warning
echo ===== Building FreeImage
%MSBUILD% %DEPSRC%FreeImage\FreeImage.2017.sln /t:Rebuild
copy /Y %DEPSRC%FreeImage\x64\Release\*.dll %DEPBIN%
copy /Y %DEPSRC%FreeImage\x64\Release\*.lib %DEPLIB%
copy /Y %DEPSRC%FreeImage\Source\FreeImage.h %DEPINC%

:freetype2
:: TODO: fix C4819 codepage(936) warning
echo ===== Building freetype2
%MSBUILD% %DEPSRC%freetype2\builds\windows\vc2010\freetype.sln /t:Rebuild
copy /Y %DEPSRC%freetype2\objs\x64\Release\*.dll %DEPBIN%
copy /Y %DEPSRC%freetype2\objs\x64\Release\*.lib %DEPLIB%
xcopy %DEPSRC%freetype2\include %DEPINC% /S /Y

:icu4c
echo ===== Building icu4c
%MSBUILD% %DEPSRC%icu4c\source\allinone\allinone.sln /t:Rebuild
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
:: TODO: Boost.Python is incompatible with (b2 --layout=tagged option and BOOST_AUTO_LINK_TAGGED)
echo ===== Building boost
set INSTALLDIR=%OGRE_DEPENDENCIES_DIR%
cd /d %DEPSRC%boost
cd
call %DEPSRC%boost\bootstrap.bat vc141
b2.exe --prefix=%INSTALLDIR% --build-dir=%BUILDDIR% -a -d+2 -q -j6 --reconfigure --debug-configuration -sICU_PATH=%DEPSRC%icu4c toolset=msvc-14.1 address-model=64 variant=release link=shared threading=multi runtime-link=shared include=%DEPINC% library-path=%DEPLIB% dll-path=%DEPBIN% cxxflags=/utf-8 optimization=space install

:Cg
echo ===== Handling Cg
xcopy %DEPSRC%Cg\bin.x64 %DEPBIN% /S /Y
xcopy %DEPSRC%Cg\lib.x64 %DEPLIB% /S /Y
xcopy %DEPSRC%Cg\include %DEPINC% /S /Y

:openexr
setlocal ENABLEEXTENSIONS
echo ===== Building OpenEXR
set INSTALLDIR=%OGRE_DEPENDENCIES_DIR%
set CXXFLAGS=/DBOOST_ALL_DYN_LINK /utf-8 %CXXFLAGS%
mkdir %BUILDDIR%openexr 1>NUL 2>&1
cd /d %BUILDDIR%openexr
cd
del /f /q CMakeCache.txt 1>NUL 2>&1
del /f /s /q *.h 1>NUL 2>&1
%CMAKE% -DBOOST_ROOT=%OGRE_DEPENDENCIES_DIR% -DBOOST_INCLUDEDIR=%DEPINC% -DBOOST_LIBRARYDIR=%DEPLIB% -DBoost_NO_SYSTEM_PATHS=ON -DZLIB_ROOT=%DEPSRC%zlib -DCMAKE_INSTALL_PREFIX=%INSTALLDIR% -DILMBASE_PACKAGE_PREFIX=%INSTALLDIR% -DOPENEXR_NAMESPACE_VERSIONING=OFF -DOPENEXR_PACKAGE_PREFIX=%INSTALLDIR% -G"Visual Studio 15 2017 Win64" %DEPSRC%openexr
%MSBUILD% %BUILDDIR%openexr\INSTALL.vcxproj /t:Rebuild
endlocal

:openssl
echo ===== Building openssl
set INSTALLDIR=%OGRE_DEPENDENCIES_DIR%
mkdir %BUILDDIR%openssl 1>NUL 2>&1
cd /d %BUILDDIR%openssl
cd
perl %DEPSRC%openssl\Configure threads shared zlib-dynamic no-asm --prefix=%INSTALLDIR% --openssldir=%INSTALLDIR% --with-zlib-include=%DEPINC% --with-zlib-lib=%DEPBIN%zlib1.dll no-deprecated no-tests VC-WIN64A
nmake install_sw

:poco
:: TODO: fix C4819 codepage(936) warning
setlocal ENABLEEXTENSIONS
echo ===== Building POCO
set INCLUDE=%INCLUDE%;%DEPSRC%poco\openssl\VS_120\include;%DEPSRC%mysql\include
set LIB=%LIB%;%DEPSRC%poco\openssl\VS_120\win64\lib\release;%DEPSRC%mysql\lib
cd /d %DEPSRC%poco
cd
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
:: TODO: fix C4819 codepage(936) warning
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
:: TODO: add zstd
echo ===== Building OGRE
set INSTALLDIR=%DP0%install\ogre
set SWIG_EXECUTABLE=%DEPSRC%swigwin\swig.exe
set CXXFLAGS=/DBOOST_ALL_DYN_LINK /utf-8 %CXXFLAGS%
mkdir %INSTALLDIR% 1>NUL 2>&1
mkdir %BUILDDIR%ogre 1>NUL 2>&1
cd /d %BUILDDIR%ogre
cd
del /f CMakeCache.txt 1>NUL 2>&1
%CMAKE% -G"Visual Studio 15 2017 Win64" -Tv141 -Wno-dev -DCMAKE_INSTALL_PREFIX=%INSTALLDIR% -DCMAKE_BUILD_TYPE="MinSizeRel" -DOGRE_BUILD_COMPONENT_JAVA:BOOL=TRUE -DOGRE_BUILD_COMPONENT_PYTHON:BOOL=TRUE -DOGRE_BUILD_DEPENDENCIES:BOOL=FALSE -DOGRE_CONFIG_THREADS=3 -DOGRE_DEPENDENCIES_DIR:PATH=%OGRE_DEPENDENCIES_DIR% -DOPENEXR_INCLUDE_DIR:PATH=%DEPINC% -DOPENEXR_Half_LIBRARY:PATH=%DEPLIB%Half.lib -DOPENEXR_Iex_LIBRARY:PATH=%DEPLIB%Iex.lib -DOPENEXR_IlmImf_LIBRARY:PATH=%DEPLIB%IlmImf.lib -DOPENEXR_IlmThread_LIBRARY:PATH=%DEPLIB%IlmThread.lib -DDirectX9_D3DX9_LIBRARY:PATH=%DirectX9_D3DX9_LIBRARY% -DSWIG_EXECUTABLE:PATH=%SWIG_EXECUTABLE% -DDOXYGEN_DOT_EXECUTABLE:PATH=%GRAPHVIZDOT% -DEGL_INCLUDE_DIR:PATH=%EGLINC% -DEGL_egl_LIBRARY:PATH=%EGL_egl_LIBRARY% -DJava_JAVAH_EXECUTABLE:PATH=%Java_JAVAH_EXECUTABLE% -DOPENGLES2_INCLUDE_DIR:PATH=%GLES2INC% -DOPENGLES2_gl_LIBRARY:PATH=%OPENGLES2_gl_LIBRARY% -DWix_BINARY_DIR:PATH=%WIXBIN% %DP0%ogre
%MSBUILD% /p:Configuration=MinSizeRel %BUILDDIR%ogre\INSTALL.vcxproj /t:Rebuild

:bye
endlocal

