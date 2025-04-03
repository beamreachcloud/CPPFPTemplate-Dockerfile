# CPPFPTemplate-Dockerfile

**CPPFPTemplate** project on **Unreal Engine 5.1** with support for building in a **Windows Docker container**.

## Preparation

### Accounts

1. Link your GitHub account to your Epic Games account:  
   https://www.unrealengine.com/en-US/ue-on-github

2. Log in to the GitHub container registry:  
   https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry

3. If something goes wrong — follow the official Epic Games guide:  
   https://dev.epicgames.com/documentation/en-us/unreal-engine/quick-start-guide-for-using-container-images-in-unreal-engine

4. Create a file at `%USERPROFILE%\.ue4-docker\credentials.json` with the following content:

```json
{
  "github_username": "your-github-username",
  "github_token": "your-personal-access-token"
}
```

### 🖥️ Host Machine Requirements

- **Docker Desktop** must be installed
- Docker should be configured to use **Windows containers**
- At least **350 GB of free disk space**
- Update Docker configuration:

Open or create the file `C:\ProgramData\Docker\config\daemon.json` and add:
In my case, Docker Desktop didn't read this file, so I also added it via the Docker Desktop UI.

```json
{
  "storage-opts": [
    "size=800GB"
  ]
}
```

Don't forget to restart Docker Desktop after making changes.

---

### Building an Image with Unreal Engine and the Project from Scratch

All PowerShell commands should be run in a command prompt with administrator rights.

1. Build the UE5.1 image:

```powershell
$env:DOCKER_BUILDKIT=""
$env:GITHUB_USERNAME="your-github-username"
$env:GITHUB_TOKEN="your-personal-access-token"
docker build -t ue5-builder --build-arg GITHUB_USERNAME=$env:GITHUB_USERNAME --build-arg GITHUB_TOKEN=$env:GITHUB_TOKEN .

```

2. Run the project build inside the container and mount the current directory to save build artifacts:

```powershell
docker run --rm -v "C:\artifacts:C:\project\BuildOutput" ue5-builder
```

4. The finished build will be available at:

```
C:\artifacts\BuildOutput\WindowsNoEditor
```

---

### Building the Windows Version of the Project Using ue5-docker:
https://github.com/NGTstudio/ue5-docker

1. Clone the repository and go into the folder:

```bash
git clone https://github.com/NGTstudio/ue5-docker.git
cd ue5-docker
```

2. Create a `.env` file and enter your GitHub credentials:

```
GITHUB_USERNAME="your-github-username"
GITHUB_TOKEN="your-personal-access-token"
```

3. Build the full image

```
docker compose --env-file .env build ue5-full
```

4. Build the image with the project

```powershell
$env:DOCKER_BUILDKIT=""
docker build -t ue5-builder -f Dockerfile.ue5-docker .
```

5. Run the project build inside the container and mount the current directory to save build artifacts:

```powershell
docker run --rm -v "C:\artifacts:C:\project" ue5-builder
```

6. The finished build will be available at:

```
C:\artifacts\BuildOutput\WindowsNoEditor
```
---

### Notes

1. The built image should remain private, as it contains metadata values (ARG GITHUB_USERNAME, ARG GITHUB_TOKEN) used during the build.
Windows containers currently do not support --secret mount.

2. It’s recommended to build an image without the project separately and use it as a base for different projects, caching it beforehand.

3. It’s a good idea to move versions of VS, UE, .Net, etc., into arguments so you can easily create different base containers for different versions using the same Dockerfile (handy for maintaining projects).

4. While developing such images, consider saving intermediate results using

5. The build uses the `visualstudio2019buildtools` toolchain. There were issues with the 2022 version.

```
docker commit <id> <name>
```
