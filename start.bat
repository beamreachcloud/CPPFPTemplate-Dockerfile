@echo off
set PROJECT_PATH=C:\project\CPPFPTemplate.uproject
set BUILD_OUTPUT=C:\project\BuildOutput

"C:\UnrealEngine\Engine\Build\BatchFiles\RunUAT.bat" ^
 -ScriptsForProject="%PROJECT_PATH%" ^
 Turnkey -command=VerifySdk -platform=Win64 -UpdateIfNeeded ^
 -EditorIO -EditorIOPort=50020 ^
 -project="%PROJECT_PATH%" ^
 BuildCookRun -nop4 -utf8output -nocompileeditor -skipbuildeditor ^
 -cook -project="%PROJECT_PATH%" ^
 -target=CPPFPTemplate ^
 -unrealexe="C:\UnrealEngine\Engine\Binaries\Win64\UnrealEditor-Cmd.exe" ^
 -platform=Win64 -installed -stage -archive -package -build ^
 -pak -iostore -compressed -prereqs ^
 -archivedirectory="%BUILD_OUTPUT%" ^
 -clientconfig=Shipping -nodebuginfo -nocompile -nocompileuat
