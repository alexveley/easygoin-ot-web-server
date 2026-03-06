# Two-Server Setup (TFS + MyAAC)

The game server **owns** the database. Create one database in the panel for the TFS server, then reuse the same credentials for this MyAAC server so both use the same data.

## 1. Create and configure the TFS game server first

- Create a server with the **TFS Game Server** egg and assign allocations (e.g. 7171, 7172).
- In the TFS server’s **Databases** tab, click **Create Database** and copy the connection details (host, port, database name, username, password).
- Paste those into the TFS server’s **Startup Variables** and start the TFS server. Wait until it shows `Forgotten Server Online`.

## 2. Configure this MyAAC server with the same database

- In this server’s **Startup Variables**, paste the **same** database credentials (MySQL Host, Port, Database, User, Password) from the TFS server. Do **not** create a separate database for this server in the panel.
- Set **Web Port** to match the allocation you assigned (e.g. 8080).

## 3. Start this server and open the site

- Start the MyAAC server.
- Open the allocation URL in a browser (e.g. `http://your-node-ip:8080`).
- Complete MyAAC setup at `/install` if prompted (database is already set via variables).

---

**Note:** Database credentials in Startup Variables are visible to admins. Using the same Pterodactyl-managed database for both servers keeps account and game data in sync.
