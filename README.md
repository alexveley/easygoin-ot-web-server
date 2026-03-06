# easygoin-ot-web-server

Docker image and Pterodactyl egg for the **MyAAC** web panel (account management, game data). Connects to the **same database** as your [TFS game server](https://github.com/alexveley/easygoin-ot-game-server). Do not create a database for this server in the panel — copy the connection details from your TFS server's Databases tab into this server's Startup Variables.

## Two-server setup

1. Create the **TFS game server** and create a database for it (Databases tab). Paste the credentials into the TFS server's variables and start it.
2. Create this **MyAAC web server**. Paste the **same** database host, user, password, database name, and port into this server's Startup Variables.
3. Start the MyAAC server and open the allocation URL (e.g. `http://your-node:8080`) to complete MyAAC setup if needed (`/install`).

## Build

```bash
docker build -t easygoin-ot-web-server:latest .
```

## Run (standalone test)

```bash
docker run --rm -e WEB_PORT=8080 -e MYSQL_HOST=host.docker.internal -e MYSQL_USER=root -e MYSQL_PASSWORD=xxx -e MYSQL_DATABASE=forgottenserver -v /path/to/myaac:/home/container/myaac -p 8080:8080 easygoin-ot-web-server:latest
```

## Pterodactyl

Import the egg from `egg-myaac-web.json`. The installation script clones MyAAC and runs Composer. Set the MySQL variables to match your TFS server's database.

See **[TWO-SERVER-SETUP.md](TWO-SERVER-SETUP.md)** for the full workflow.
