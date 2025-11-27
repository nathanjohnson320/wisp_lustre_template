# wisp_lustre_template

A full-stack web application template built with [Gleam](https://gleam.run/), featuring:

- **Backend**: [Wisp](https://hexdocs.pm/wisp/) web framework running on Erlang/OTP
- **Frontend**: [Lustre](https://hexdocs.pm/lustre/) reactive UI framework compiled to JavaScript
- **Database**: PostgreSQL with [pog](https://hexdocs.pm/pog/) for database access
- **Example App**: A complete todo list application demonstrating CRUD operations

## Project Structure

- `common/` - Shared Gleam library (multi-target)
  - Shared data models and types
  - JSON encoders/decoders
  - Business logic used by both frontend and backend
  - Example: `Item` type with status management
- `server/` - Backend Gleam project (Erlang target)
  - REST API endpoints
  - Database migrations with dbmate
  - SQL query generation with Squirrel
  - Example routes for todo items
- `ui/` - Frontend Gleam project (JavaScript target)
  - Lustre-based reactive UI
  - HTTP client using `lustre_http`
  - Routing with `modem`
  - Development server with Vite

## Prerequisites

- [Gleam](https://gleam.run/getting-started/) installed
- [Erlang/OTP](https://www.erlang.org/downloads) installed
- [PostgreSQL](https://www.postgresql.org/download/) installed and running
- [Node.js](https://nodejs.org/) and npm installed
- [dbmate](https://github.com/amacneil/dbmate) for database migrations (optional, but recommended)

## Getting Started

### 1. Database Setup

Set up the database URL and secret key in a `.env` file (or environment variables):

```bash
DATABASE_URL=postgres://user:password@localhost:5432/database_name
SECRET_KEY_BASE=your-secret-key-here
PORT=9999
```

Make sure PostgreSQL is installed and running, and create a database for your application:

```bash
createdb database_name
```

Run database migrations:

```bash
cd server
npm install  # Installs dbmate
npm run db:up
```

### 2. Backend Server

Start the backend server:

```bash
cd server
gleam run
```

The server will start on port 9999 (or the port specified in `PORT`).

### 3. Frontend Development

In a separate terminal, start the frontend development server:

```bash
cd ui
npm install
npm run dev
```

Visit `http://localhost:5173` (or the port Vite assigns) to see the application.

### 4. Production Build

Build the frontend for production:

```bash
cd ui
npm run build
```

The built assets will be in `ui/build/prod/javascript/`. The server serves static files from `server/priv/static/`.

## Features

- ✅ RESTful API with Wisp
- ✅ Database access with pog (PostgreSQL support)
- ✅ SQL query generation with Squirrel
- ✅ Type-safe frontend with Lustre
- ✅ HTTP client with `lustre_http`
- ✅ Client-side routing with `modem`
- ✅ Database migrations with dbmate
- ✅ CORS support
- ✅ Development tooling (Vite for frontend, Gleam LSP support)

## Example API Endpoints

The template includes example todo item endpoints:

- `GET /items` - List all items
- `POST /items` - Create a new item
- `PATCH /items/:id` - Update an item
- `DELETE /items/:id` - Delete an item

## Development

### Running Tests

```bash
# Backend tests
cd server
gleam test

# Frontend tests
cd ui
gleam test
```

### Database Migrations

```bash
cd server
npm run db:new <migration_name>  # Create new migration
npm run db:up                     # Run pending migrations
npm run db:down                    # Rollback last migration
npm run db:status                  # Check migration status
```

### SQL Query Generation

This project uses [Squirrel](https://github.com/giacomocavalieri/squirrel) to generate type-safe Gleam functions from SQL files. SQL queries are stored in `server/src/app/sql/` and the generated Gleam code is in `server/src/app/sql.gleam`.

After creating or modifying SQL files, regenerate the Gleam code:

```bash
cd server
npm run db:gen:sql
```

## Learn More

- [Gleam Language Documentation](https://gleam.run/documentation/)
- [Wisp Framework](https://hexdocs.pm/wisp/)
- [Lustre Framework](https://hexdocs.pm/lustre/)
- [pog Database Library](https://hexdocs.pm/pog/)
- [Squirrel SQL Generator](https://github.com/giacomocavalieri/squirrel)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
