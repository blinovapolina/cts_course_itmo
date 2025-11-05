# Лабораторная работа №3 (Часть 2)

## Вторая часть лабораторной работы

### Цели

Полный текст задания представлен в репозитории: https://github.com/inview-club/devops-cases/blob/main/05-whitespots/README-ru.md

- Реализовать развертывание платформы безопасности - установить и настроить WhiteSpots (AppSec Portal + Auditor)
- Найти и проанализировать уязвимости в проекте
- Обеспечить отображение уязвимостей непосредственно в IDE

### Введение

Whitespots — это платформа для обнаружения и управления уязвимостями в приложениях. \
AppSec Portal - это веб-интерфейс всей платформы. \
Auditor - это движок, который выполняет анализ кода.

### Выполнение работы

#### Установка WhiteSpots (AppSec Portal + Auditor)

В документации (https://docs.whitespots.io/appsec-portal/deployment/installation) через docker compose указана комплексная установка всего стека (PostgreSQL, Rabbitmq и тд), которая больше подходит для продакшена и тестовых окружений с базами данных. \
Cначала для этой работы я выбрала более упрощенный способ установки: через уже собранный портал из образа `registry.whitespots.io/appsec-portal:latest`, - однако так как для этого способа нужен приватный доступ, вернулась к выполнению установки по инструкции из документации.

1. Сначала была создана папка `whitespots`, куда был склонирован репозиторий `https://gitlab.com/whitespots-public/appsec-portal.git`. После этого я перешла в папку `appsec-portal`
   <img width="1119" height="185" alt="image" src="https://github.com/user-attachments/assets/4a6a1b0e-ea77-40ee-b435-6d5ec9567e01" />

2. В корневом каталоге выполнила следующую команду для запуска скрипта `./set_vars.sh` (полное описание всех переменных, которые запрашивает скрипт, находится в документации по ссылке выше). Этот скрипт генерирует `.env` файл. Позже в самом файле я добавила версию образа (так как изначально при настройке забыла ее указать), а также лицензионный ключ, который был получен ранее
  <img width="663" height="293" alt="image" src="https://github.com/user-attachments/assets/4d96486f-37bc-4ce1-b422-877db33bf6b9" />

3. С помощью команды `sh run.sh` запустила портал AppSec. При выполнении этой команды вылезла ошибка, в которой появилась ошибка с доступом
<img width="1217" height="364" alt="image" src="https://github.com/user-attachments/assets/a3dac287-c8d2-4ebc-b82e-2bd92a8fbd8a" />

4. Я произвела регистрацию на платформе `https://gitlab.com/users/sign_up`, добавила access-token, а затем попробовала снова ввести команду `sh run.sh`. Лог очень большой (не все есть на скринах), но где-то выскакивает проблема, что эти образы собраны под amd64, а у меня Apple Silicon (arm64), поэтому образы вроде `back`, `importer`, `jira_helper` зависают или падают. C помощью команды `docker-image` проверила собранные образы. Тут есть `appsec`, поэтому на проблемы с остальным можно не обращать внимание
  <img width="1255" height="815" alt="image" src="https://github.com/user-attachments/assets/72d1c129-d00c-4078-bd1e-7465729c3663" />
  <img width="1219" height="86" alt="image" src="https://github.com/user-attachments/assets/ff0a51bd-9b60-4de8-94de-849f4a885834" />
  <img width="1222" height="724" alt="image" src="https://github.com/user-attachments/assets/57de1bf1-b71b-425d-9efc-3ce2854eb329" />
  <img width="1223" height="746" alt="image" src="https://github.com/user-attachments/assets/57f67617-4f56-4bf0-a57d-1437f19f92ce" />
  <img width="1220" height="747" alt="image" src="https://github.com/user-attachments/assets/4ea98e52-9480-4eb5-add1-8a7e56191192" />
  <img width="1218" height="220" alt="image" src="https://github.com/user-attachments/assets/eeb7c0a2-3a55-4fb4-9de9-8d7da8c24a05" />

5. Дальше скачивание Auditor по такой же схеме (https://docs.whitespots.io/auditor/deployment/installation)
  <img width="1192" height="185" alt="image" src="https://github.com/user-attachments/assets/61d0e39c-e830-49cb-8ec9-e93ecdd67cf4" />
  <img width="1203" height="274" alt="image" src="https://github.com/user-attachments/assets/367d64bb-2980-423a-88eb-87498b0a9dfe" />
