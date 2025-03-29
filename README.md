# CPPFPTemplate-Dockerfile

Проект **CPPFPTemplate** на **Unreal Engine 5.1** с поддержкой сборки в **Windows-контейнере Docker**.

## Подготовка

### Аккаунты

1. Привязываем GitHub-аккаунт к аккаунту Epic Games:  
   https://www.unrealengine.com/en-US/ue-on-github

2. Логинимся в реестр контейнеров GitHub:  
   https://docs.github.com/ru/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry

3. Если что-то идёт не так — воспользуйтесь официальной инструкцией Epic Games:  
   https://dev.epicgames.com/documentation/en-us/unreal-engine/quick-start-guide-for-using-container-images-in-unreal-engine

4. Создаём файл `%USERPROFILE%\.ue4-docker\credentials.json` со следующим содержимым:

```json
{
  "github_username": "ваше-имя-пользователя-github",
  "github_token": "ваш-personal-access-token"
}
```

### 🖥️ Требования к хост-машине

- Установлен **Docker Desktop**
- Docker настроен на **режим Windows-контейнеров**
- Свободно **не менее 350 ГБ** на диске
- Обновляем конфигурацию Docker:

Открываем или создаём файл `C:\ProgramData\Docker\config\daemon.json` и добавляем:
У меня этот файл Docker Desktop не прочитался, поэтому дописал ещё и в конфигурацию DD через UI

```json
{
  "storage-opts": [
    "size=800GB"
  ]
}
```

Не забываем перезапустить Docker Desktop после изменений.

---

### Сборка образа с Unreal Engine и проектом c нуля

Все powershell команды запускаем в командной строке с правами администратора

1. Выполняем сборку образа UE5.1:

```powershell
$env:DOCKER_BUILDKIT=""
$env:GITHUB_USERNAME="your-github-username"
$env:GITHUB_TOKEN="your-personal-access-token"
docker build -t ue5-builder --build-arg GITHUB_USERNAME=$env:GITHUB_USERNAME --build-arg GITHUB_TOKEN=$env:GITHUB_TOKEN .

```

2. Запускаем сборку проекта внутри контейнера и монтируем текущую директорию для сохранения артефактов:

```powershell
docker run --rm -v "C:\artifacts:C:\project\BuildOutput" ue5-builder
```

4. Готовый билд будет доступен по пути:

```
C:\artifacts\BuildOutput\WindowsNoEditor
```

---

### Сборка Windows-версии проекта c использованием ue5-docker:
https://github.com/NGTstudio/ue5-docker

1. Клонируем репозиторий и переходим в папку:

```bash
git clone https://github.com/NGTstudio/ue5-docker.git
cd ue5-docker
```

2. Создаём файл .env и указываем свои GitHub-учётные данные:

```
GITHUB_USERNAME="your-github-username"
GITHUB_TOKEN="your-personal-access-token"
```

3. Собираем полный образ

```
docker compose --env-file .env build ue5-full
```

4. Собираем образ с проектом

```powershell
$env:DOCKER_BUILDKIT=""
docker build -t ue5-builder -f Dockerfile.ue5-docker .
```

5. Запускаем сборку проекта внутри контейнера и монтируем текущую директорию для сохранения артефактов:

```powershell
docker run --rm -v "C:\artifacts:C:\project" ue5-builder
```

6. Готовый билд будет доступен по пути:

```
C:\artifacts\BuildOutput\WindowsNoEditor
```
---

### Комментарии

1. Собранный имадж должен оставаться закрытым, так как содержит в метадата значения (ARG GITHUB_USERNAME, ARG GITHUB_TOKEN), указанные при сборке.
Windows контейнеры не поддерживают пока --secret mount

2. Рекомендую собрать отдельно имадж без проекта и использовать как базовый для разных проектов, предварительно его закэшировав

3. Версии VS, UE, .Net, итд рекомендую вынести как аргументы, чтобы можно было клепать на разные версии разные базовые контейнеры, переиспользуя один докерфайл (удобно для поддержки проектов)

4. Во время разработки подобных имаджей, рекомендую сохранять промежуточные результаты при помощи

5. Собираем при помощи visualstudio2019buildtools тулчейна. С 2022 версией возникали проблемы.

```
docker commit <id> <name>
```