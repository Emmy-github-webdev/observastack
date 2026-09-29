# ObservaStack Services

The application layer contains four independently deployable services.

| Service | Responsibility | Default port |
|---|---|---:|
| user-service | User/profile operations | 8080 |
| product-service | Product/catalog operations | 8080 |
| order-service | Order lifecycle | 8080 |
| payment-service | Payment lifecycle boundary | 8080 |

Services intentionally keep their APIs small in this foundation phase. Persistence, messaging and external integrations are introduced through explicit contracts rather than hidden coupling.
