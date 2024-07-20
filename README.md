# yb-perf-hub

🧪 experimental dashboard on YugabyteDB Active Session history
⚠️  this creates a superuser (gv$fdw) with a random password (to use with FDW) and remote tables and views to query ASH on all nodes

1. set the IP of one node of your YugabyteDB cluster in `.env` (the IP, not the hostname, because this goes to /etc/hosts in the container)

2. Start this with
```
docker compose up
```

3. Go to http://localhost:3000 (user admin password admin)

4. Update the data source to any node on your YugabyteDB cluster

5. Go to home, Active Session Dashboard, and select your data source if you added a new one

---

When loading the ASH dashboard, it creates some Foreign Data Wrapper and views to see all nodes
The code is in the 'server' variable definition of the Active Session History dashboard

---

Example:

![image](https://github.com/FranckPachot/yb-perf-hub/assets/33070466/57450e23-13f0-4154-bdee-c4ea31204def)

## Test in a local lab by starting a RF3 YugabyteDB cluster

You can experiment in a local lab starting a YugabyteDB cluster with docker compose:
```
# start RF3 YugabyteFB
docker compose -f docker-compose-startyb.yaml down
docker compose -f docker-compose-startyb.yaml up -d  yugabytedb --scale yugabytedb=1 --no-recreate
until docker compose -f docker-compose-startyb.yaml exec yugabytedb postgres/bin/pg_isready -h yb-perf-hub-yugabytedb-1 ; do sleep 1 ; done | paste -s | uniq
docker compose -f docker-compose-startyb.yaml up -d  yugabytedb --scale yugabytedb=2 --no-recreate
until docker compose -f docker-compose-startyb.yaml exec yugabytedb postgres/bin/pg_isready -h yb-perf-hub-yugabytedb-2 ; do sleep 1 ; done | paste -s | uniq
docker compose -f docker-compose-startyb.yaml up -d  yugabytedb --scale yugabytedb=3 --no-recreate
until docker compose -f docker-compose

# define IP to one node and start Grafana dashboard
sed -e '$a'"ip_of_yugabytedb_database=$(docker compose -f docker-compose-startyb.yaml exec yugabytedb hostname -i)"  .env > .lab.env
docker compose --env-file=.lab.env up -d 

# run your stuff in psql (default password is yugabyte)
docker compose exec -it yugabytedb ysqlsh -h yb-perf-hub-yugabytedb-1

```




