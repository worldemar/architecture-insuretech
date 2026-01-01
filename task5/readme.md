# Задание 5. Проектирование GraphQL API

## Анализ контракта Swagger (client-inf)

Полный контракт находится в файле [client-inf.yml](client-inf.yml).

Основные сущности:

- **Client (Клиент)**: содержит базовую информацию (ID, имя, возраст).
- **Document (Документ)**: сведения о документах клиента (ID, тип, номер, даты выдачи и окончания).
- **Relative (Родственник)**: информация о родственниках (ID, тип родства, имя, возраст).

Текущие эндпоинты:

- `GET /clients/{id}`: Базовая информация о клиенте.
- `GET /clients/{id}/documents`: Список документов конкретного клиента.
- `GET /clients/{id}/relatives`: Список родственников конкретного клиента.

Проблема текущего подхода:

Для получения полного профиля клиента (данные + документы + родственники) фронтенду или другим сервисам необходимо выполнить 3 отдельных HTTP-запроса. Это увеличивает нагрузку (RPS) на сервис `client-info` и замедляет отрисовку страниц в веб-приложении из-за последовательных или параллельных сетевых задержек.

## Эквивалентная схема GraphQL

Содержится в файле [client-inf.graphql](client-inf.graphql)

## Покрытие REST API с помощью GraphQL 

GraphQL схема полностью покрывает функциональность REST API:

1.  **Получение базовой информации о клиенте** (`GET /clients/{id}`):
    ```graphql
    query {
      client(id: "123") {
        id
        name
        age
      }
    }
    ```

2.  **Получение документов клиента** (`GET /clients/{id}/documents`):
    ```graphql
    query {
      client(id: "123") {
        documents {
          id
          type
          number
          issueDate
          expiryDate
        }
      }
    }
    ```

3.  **Получение родственников клиента** (`GET /clients/{id}/relatives`):
    ```graphql
    query {
      client(id: "123") {
        relatives {
          id
          relationType
          name
          age
        }
      }
    }
    ```

4.  **Комбинированный запрос (решение проблемы множественных запросов)**:
    ```graphql
    query {
      client(id: "123") {
        name
        documents {
          type
          number
        }
        relatives {
          relationType
          name
        }
      }
    }
    ```
