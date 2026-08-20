# bt-backend

API REST (Vapor 4 / Swift) do BT200 — usada por `btuser-frontend` (jogador) e `btgestor-frontend` (gestor de arena).

## Rodar localmente

```bash
# pré-requisito: bt-shared clonado ao lado (../bt-shared)
swift run App serve --hostname 0.0.0.0 --port 8080
curl localhost:8080/health
```

SQLite (`db.sqlite`) é criado automaticamente com dados de exemplo:

| usuário | senha | app |
|---|---|---|
| `jogador@bt.dev` | `123456` | btuser |
| `gestor@bt.dev`  | `123456` | btgestor |

Postgres: `docker compose up -d db` e `DATABASE_URL=postgres://bt:bt@localhost:5432/bt200 swift run App serve`.

## Rotas (`/api/v1`)

| método | rota | quem | descrição |
|---|---|---|---|
| POST | `/auth/register` | público | cria usuário (`role`: player/manager) |
| POST | `/auth/login` | público | retorna JWT |
| GET | `/me` | auth | usuário logado |
| GET | `/arenas` | auth | jogador: todas; gestor: as suas |
| POST | `/arenas` | gestor | cria arena |
| GET | `/arenas/:id` | auth | detalhe |
| GET | `/arenas/:id/courts` | auth | quadras ativas |
| GET | `/bookings` | auth | jogador: suas reservas; gestor: reservas das suas arenas |
| POST | `/bookings` | jogador | reserva (valida conflito de horário) |
| DELETE | `/bookings/:id` | auth | cancela |

Os tipos de request/response são os DTOs de `bt-shared` — não redefina aqui.

## Deploy

`Dockerfile` pronto (Fly.io, Railway, Render, VPS). Variáveis: `DATABASE_URL`, `JWT_SECRET`.
