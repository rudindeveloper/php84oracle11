# PHP 8.4 Oracle Docker

Docker-проект с PHP 8.4 и поддержкой Oracle Database 11 версии.

## Технологии

- PHP 8.4
- Oracle Instant Client
- Nginx
- Docker / Docker Compose

## Структура проекта

```
.
├── docker-compose.yml    # Конфигурация Docker Compose
├── Dockerfile            # Сборка PHP-образа
├── nginx.conf            # Конфигурация Nginx
├── src/                  # Исходный код приложения
│   └── index.php         # Главный файл приложения
└── README.md             # Этот файл
```

## Быстрый старт

### Запуск контейнеров

```bash
docker-compose up -d
```

### Остановка контейнеров

```bash
docker-compose down
```

### Просмотр логов

```bash
docker-compose logs -f
```

## Доступ

- Приложение: http://localhost:8080
- phpinfo(): http://localhost:8080/info.php

## Подключение к базе данных

В файле `src/index.php` представлен пример подключения к БД через PDO. Замените параметры подключения на свои:

```php
$dsn = 'mysql:host=localhost;dbname=testdb;charset=utf8mb4';
$username = 'username';
$password = 'password';
```

## Переменные окружения

Настройте переменные окружения в `docker-compose.yml` для подключения к вашей базе данных Oracle.
