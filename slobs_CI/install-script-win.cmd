set DEPS=dependencies2019.0
set DepsURL=https://obs-studio-deployment.s3-us-west-2.amazonaws.com/%DEPS%.zip
set VLCURL=https://obsproject.com/downloads/vlc.zip
set CEFURL=https://s3-us-west-2.amazonaws.com/streamlabs-cef-dist
set CMakeGenerator=Visual Studio 16 2019
set CefFileName=cef_binary_%CEF_VERSION%_windows64_minimal
set GPUPriority=1

mkdir build
cd build

if exist %DEPS%.zip (curl -kLO %DepsURL% -f --retry 5 -z %DEPS%.zip) else (curl -kLO %DepsURL% -f --retry 5 -C -)
if exist vlc.zip (curl -kLO %VLCURL% -f --retry 5 -z vlc.zip) else (curl -kLO %VLCURL% -f --retry 5 -C -)
if exist %CefFileName%.zip (curl -kLO %CEFURL%/%CefFileName%.zip -f --retry 5 -z %CefFileName%.zip) else (curl -kLO %CEFURL%/%CefFileName%.zip -f --retry 5 -C -)

7z x %DEPS%.zip -aoa -o%DEPS%
7z x vlc.zip -aoa -ovlc
7z x %CefFileName%.zip -aoa -oCEF

set CEFPATH=%CD%\CEF\%CefFileName%
set BuildConfig=Debug
set InstallPath=\build\pack_node

cmake -G"%CMakeGenerator%" -A x64 -H%CEFPATH% -B%CEFPATH%\build -DCEF_RUNTIME_LIBRARY_FLAG="/MD"
cmake --build %CEFPATH%\build --config %CefBuildConfig% --target libcef_dll_wrapper -v

cd ..

cmake -H. ^
         -B%CD%\build ^
         -G"%CmakeGenerator%" ^
         -A x64 ^
         -DCMAKE_SYSTEM_VERSION=10.0 ^
         -DCMAKE_INSTALL_PREFIX=%CD%\%InstallPath% ^
         -DDepsPath=%CD%\build\%DEPS%\win64 ^
         -DVLCPath=%CD%\build\vlc ^
         -DCEF_ROOT_DIR=%CEFPATH% ^
         -DUSE_UI_LOOP=false ^
         -DENABLE_UI=false ^
         -DCOPIED_DEPENDENCIES=false ^
         -DCOPY_DEPENDENCIES=true ^
         -DENABLE_SCRIPTING=false ^
         -DGPU_PRIORITY_VAL="%GPUPriority%" ^
         -DBUILD_CAPTIONS=false ^
         -DCOMPILE_D3D12_HOOK=true ^
         -DBUILD_BROWSER=false ^
         -DBROWSER_FRONTEND_API_SUPPORT=false ^
         -DBROWSER_PANEL_SUPPORT=false ^
         -DBROWSER_USE_STATIC_CRT=false ^
         -DEXPERIMENTAL_SHARED_TEXTURE_SUPPORT=true ^
         -DCHECK_FOR_SERVICE_UPDATES=true

cmake --build %CD%\build --target install --config %BuildConfig% -v
