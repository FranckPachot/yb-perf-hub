# yb-perf-hub

🧪 experimental dashboard on YugabyteDB Active Session history

1. set the IP of one node of your YugabyteDB cluster in `.env` (the IP, not the hostname, because this goes to /etc/hosts in the container)

2. Start this with
```
docker compose up
```

3. Go to http://localhost:3000 (user admin password admin)

- If you have set the IP in `.env` the default data source goes to it and you can go to the Active Session History dashboard

If not, you can create more data sources:

4. Set your data source to any node on your YugabyteDB cluster

5. Go to home and select your data source

---

⚠️ When loading the ASH dashboard, it creates some Foreign Data Wrapper and views to see all nodes

---

Example:

![image](https://github.com/FranckPachot/yb-perf-hub/assets/33070466/57450e23-13f0-4154-bdee-c4ea31204def)

## Test in a local lab by starting a RF3 YugabyteDB cluster

You can experiment in a local lab starting a YugabyteDB cluster with docker compose:
```
docker compose down

# start RF3 YugabyteFB
docker compose up -d  yugabytedb --scale yugabytedb=1
until docker compose exec yugabytedb postgres/bin/pg_isready -h yb-perf-hub-yugabytedb-1 ; do sleep 1 ; done | uniq
docker compose up -d  yugabytedb --scale yugabytedb=2
until docker compose exec yugabytedb postgres/bin/pg_isready -h yb-perf-hub-yugabytedb-2 ; do sleep 1 ; done | uniq
docker compose up -d  yugabytedb --scale yugabytedb=3

# define IP to one node and start Grafana dashboard
sed -e '$a'"ip_of_yugabytedb_database=$(docker compose exec yugabytedb hostname -i)"  .env > .lab.env
docker compose --env-file=.lab.env up --scale yugabytedb=3

# run your stuff in psql
docker compose exec -it yugabytedb ysqlsh -h yb-perf-hub-yugabytedb-1

```




