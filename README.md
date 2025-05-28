# pgmock

Mocking your [PostgreSQL](https://www.postgresql.org/) database when your programming language ecosystem doesn't support mocks.

We'll run a PostgreSQL database and [PostgREST](https://postgrest.org/en/stable/index.html) in Docker containers. Schema(s) needs to be created in the database, and PostgREST will expose all CRUD operations on the schema(s) as a RESTful API.

Docker images:
* https://hub.docker.com/_/postgres
* https://hub.docker.com/r/postgrest/postgrest

Run PostgreSQL and PostgREST in Docker containers with `docker compose`:
```
docker compose build
docker compose up
docker compose down
```

You will tailor the database schema and initial data to your needs with [schema.sql](schema.sql) file and by building the tailored PostgreSQL Docker image with [`docker-compose.override.yml`](docker-compose.override.yml).

See [`schema.sql`](schema.sql) file for the example schema and data (copied from the official PostgREST [tutorial](https://postgrest.org/en/stable/tutorials/tut0.html)).

## How to Use PostgreSQL

Run `psql` in the Docker container:
```
# interactive psql shell
docker exec --interactive --tty pgmockdb psql --username mock_user --dbname mock_db

# run sql commands from a file
docker exec --interactive pgmockdb psql --username mock_user --dbname mock_db < example.sql
```

## How to Use PostgREST

Reload the PostgREST schema cache:
```
docker compose kill -s SIGUSR1 pgmockrest
```

Access the database with PostgREST API:
```
# openapi spec
curl http://localhost:3000

# query all rows from table `todos`
curl http://localhost:3000/todos

# insert a new row
curl http://localhost:3000/todos \
 -H "Content-Type: application/json" \
 -d '{"task": "new task"}'

# update a row
curl -X PATCH 'http://localhost:3000/todos?id=eq.3' \
 -H "Content-Type: application/json" \
 -d '{"done": true}'

# delete a row
curl -X DELETE 'http://localhost:3000/todos?id=eq.3'
```

## How to Connect InterSystems IRIS Interoperability Production to PostgreSQL

### SQL Gateway Setup

[SQL Gateway](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=BSQG_overview) is the IRIS concept which allows you to connect to external databases like PostgreSQL.

In Management Portal:
```
System Administration
 > Configuration
  > Connectivity
   > SQL Gateway Connections
    > Create New Connection
```

It's not yet known how this can be done programmatically.

Set values to:

|Parameter      |Value|
|---------------|-----|
|Type of connection|`JDBC`|
|Connection name|`pgmockdb`|
|User           |`mock_user`|
|Password       |`password`|
|Driver name    |`org.postgresql.Driver`|
|URL            |`jdbc:postgresql://pgmockdb:5432/mock_db`|
|Class path     |`/usr/irissys/lib/postgresql-42.7.5.jar`|

You'll find the PostgreSQL JDBC driver in https://jdbc.postgresql.org/

### Interoperability (IOP) Production Setup

An IOP Production have to host a [`EnsLib.JavaGateway.Service`](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=ESQL_bo#ESQL_outbound_specifying_dsn) _business service_.

For `EnsLib.SQL.OutboundAdapter` based _business operation_ set the following properties:

|Property           |Value     |Description|
|-------------------|----------|-----------|
|`Adapter.DSN`      |`pgmockdb`|SQL Gateway connection name|
|`Adapter.JGService`|`EnsLib.JavaGateway.Service`|Name of the Java Gateway (Business) Service|

Make sure your Docker network is shared with the IRIS instance.