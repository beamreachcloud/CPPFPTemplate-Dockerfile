# Use Microsoft's SDK image with MSBuild and VC++ preinstalled
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-20230411-windowsservercore-ltsc2022

ARG GITHUB_USERNAME
ARG GITHUB_TOKEN

# --- Install Chocolatey & Git ---
SHELL ["powershell", "-Command"]
RUN iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

SHELL ["cmd", "/S", "/C"]
RUN choco install git -y && \
    choco install vcredist140 -y && \
    choco install dotnet-6.0-sdk -y && \
    choco install 7zip -y && \
    choco install sysinternals -y

# --- Clone Unreal Engine 5.1 ---
WORKDIR C:\\
RUN git clone --branch=5.1 https://%GITHUB_USERNAME%:%GITHUB_TOKEN%@github.com/EpicGames/UnrealEngine.git


WORKDIR C:\\UnrealEngine
RUN git config --global --add safe.directory C:\\UnrealEngine
RUN git submodule update --init --recursive

RUN choco install visualstudio2022buildtools --yes --ignore-checksums --no-progress --params="'\
  --add Microsoft.VisualStudio.Workload.VCTools \
  --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
  --add Microsoft.VisualStudio.Component.Windows11SDK.22621 \
  --add Microsoft.VisualStudio.Workload.MSBuildTools \
  --add Microsoft.VisualStudio.Component.VC.CoreBuildTools \
  --add Microsoft.VisualStudio.Component.VC.Tools.ARM64 \
  --includeRecommended --includeOptional'"

# --- Clear temp files and reduce layer sizes ---
RUN del /q/f/s %TEMP%\* && rmdir /s/q %TEMP%

# --- Patch Setup.bat to skip GUI installers ---
RUN powershell -Command "(Get-Content Setup.bat) -replace 'start /wait Engine.*UEPrereqSetup_x64.exe.*', 'rem Skipped prereqs installer' | Set-Content Setup.bat"
RUN powershell -Command "(Get-Content Setup.bat) -replace '.*UnrealVersionSelector-Win64-Shipping.exe /register.*', 'rem Skipped UnrealVersionSelector registration' | Set-Content Setup.bat"

# --- Run setup scripts ---
ENV SkipUnrealVersionSelector=true
RUN Setup.bat

RUN choco install visualstudio2019buildtools --version=16.11.45 --yes --ignore-checksums --no-progress --params "'\
  --add Microsoft.VisualStudio.Workload.VCTools \
  --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
  --add Microsoft.VisualStudio.Component.Windows10SDK.19041 \
  --add Microsoft.VisualStudio.Workload.MSBuildTools \
  --add Microsoft.VisualStudio.Component.VC.CoreBuildTools \
  --includeRecommended --includeOptional --norestart'" > C:\\vs2019.log 2>&1 || type C:\\vs2019.log

ENV PATH="C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\VC\\Tools\\MSVC\\14.38.33130\\bin\\Hostx64\\x64;C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\MSBuild\\Current\\Bin;%PATH%"

RUN GenerateProjectFiles.bat

# --- Build required tools ---
RUN Engine\\Build\\BatchFiles\\Build.bat UnrealBuildTool Win64 Development
RUN Engine\\Build\\BatchFiles\\Build.bat UnrealHeaderTool Win64 Development
RUN Engine\\Build\\BatchFiles\\Build.bat ShaderCompileWorker Win64 Development
RUN Engine\\Build\\BatchFiles\\Build.bat UnrealLightmass Win64 Development
RUN Engine\\Build\\BatchFiles\\Build.bat UnrealPak Win64 Development
RUN Engine\\Build\\BatchFiles\\Build.bat UnrealFrontend Win64 Development
RUN Engine\\Build\\BatchFiles\\Build.bat AutomationTool Win64 Development

# --- Copy your UE project into the container ---
WORKDIR C:\\project
COPY . C:\\project

# --- Final command: Build & package the project using UAT ---
CMD cmd /S /C "\"C:\\UnrealEngine\\Engine\\Build\\BatchFiles\\RunUAT.bat\" -ScriptsForProject=\"C:\\project\\CPPFPTemplate.uproject\" Turnkey -command=VerifySdk -platform=Win64 -UpdateIfNeeded -EditorIO -EditorIOPort=50020 -project=\"C:\\project\\CPPFPTemplate.uproject\" BuildCookRun -nop4 -utf8output -nocompileeditor -skipbuildeditor -cook -project=\"C:\\project\\CPPFPTemplate.uproject\" -target=CPPFPTemplate -unrealexe=\"C:\\UnrealEngine\\Engine\\Binaries\\Win64\\UnrealEditor-Cmd.exe\" -platform=Win64 -installed -stage -archive -package -build -pak -iostore -compressed -prereqs -archivedirectory=\"C:\\project\\BuildOutput\" -clientconfig=Shipping -nodebuginfo -nocompile -nocompileuat"
