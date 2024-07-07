# yb-perf-hub

🧪 experimental dashboard on YugabyteDB Active Session history

1. set the IP of one node of your YugabyteDB cluster in `.env`

2. Start this with
```
docker compose up
```

3. Go to http://localhost:3000 (user admin password admin)

If you have set the IP in `.env` the default data source goes to it and you can go to the Active Session History dashboard

If not, you can create more data sources:

4. Set your data source to any node on your YugabyteDB cluster

5. Go to home and select your data source

---

⚠️ When loading the ASH dashboard, it creates some Foreign Data Wrapper and views to see all nodes

---

Example:

![image](https://github.com/FranckPachot/yb-perf-hub/assets/33070466/57450e23-13f0-4154-bdee-c4ea31204def)


