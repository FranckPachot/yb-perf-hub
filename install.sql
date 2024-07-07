/*
the same is run automatically from the dashboard in the variable `server`
(and this file might be stale as I update the dashboard)
*/




drop function if exists yb_ash_fdw;
create function yb_ash_fdw(
 username text default 'yugabyte', password text default 'yugabyte'
) returns table ("__text" text, "__value" text) as $PL$
 declare
  ddl record;
 begin
  execute 'create extension if not exists postgres_fdw';
  execute 'drop foreign data wrapper if exists yb_ash_fdw cascade';
  execute 'create foreign data wrapper yb_ash_fdw handler postgres_fdw_handler';
  for ddl in (
    select format('
     create server if not exists "gv$%1$s"
     foreign data wrapper yb_ash_fdw
     options (host %2$L, port %3$L, dbname %4$L)
     ', host, host, port, current_database()) as sql
     from yb_servers()
  ) loop
   raise notice '(create server) SQL: %', ddl.sql ; execute ddl.sql;
  end loop;
  for ddl in (
    select format('
     create user mapping if not exists for current_user
     server "gv$%1$s"
     ',host, username, password ) as sql
     from yb_servers()
  ) loop
   raise notice '(create user mapping) SQL: %', ddl.sql ; execute ddl.sql;
  end loop;
  for ddl in (
    select format('
     drop schema if exists "gv$%1$s" cascade
     ',host) as sql
     from yb_servers()
  ) loop
   raise notice '(drop schema) SQL: %', ddl.sql ; execute ddl.sql;
  end loop;
  for ddl in (
    select format('
     create schema if not exists "gv$%1$s"
     ',host) as sql
     from yb_servers()
  ) loop
   raise notice '(create schema) SQL: %', ddl.sql ; execute ddl.sql;
  end loop;
  for ddl in (
    select format('
     import foreign schema "pg_catalog"
     limit to ("yb_active_session_history","pg_stat_statements","yb_local_tablets")
     from server "gv$%1$s" into "gv$%1$s"
     ', host) as sql from yb_servers()
  ) loop
   raise notice '(import foreign schema) SQL: %', ddl.sql ; execute ddl.sql;
  end loop;
  for ddl in (
    with views as (
    select distinct foreign_table_name
    from information_schema.foreign_tables t, yb_servers() s
    where foreign_table_schema = format('gv$%1$s',s.host)
    )
    select format('create view public."gv$%2$s" as %1$s',
     string_agg(
     format('
     select %2$L as gv$host, %3$L as gv$zone, %4$L as gv$region, %5$L as gv$cloud,
     * from "gv$%2$s".%1$I
     ', foreign_table_name, host, zone, region, cloud)
     ,' union all '), foreign_table_name
    ) as sql from views, yb_servers() group by views.foreign_table_name
  ) loop
   raise notice '(create views) SQL: %', ddl.sql ; execute ddl.sql;
  end loop;
  return query 
select distinct format('%s.%s.%s %s',gv$cloud,gv$region,gv$zone,gv$host) as "__text" , gv$host as "__value"
from gv$yb_active_session_history  where '$agg'='Host'
union all
select distinct format('%s.%s.%s',gv$cloud,gv$region,gv$zone,gv$host) as "__text" , gv$zone as "__value"
from gv$yb_active_session_history where '$agg'='Zone'
union all
select distinct format('%s.%s',gv$cloud,gv$region,gv$zone,gv$host) as "__text" , gv$region as "__value"
from gv$yb_active_session_history where '$agg'='Region'
union all
select distinct format('%s',gv$cloud,gv$region,gv$zone,gv$host) as "__text" , gv$cloud as "__value"
from gv$yb_active_session_history where '$agg'='Cloud'
;
 end;
$PL$ language plpgsql;



select "__text", "__value" from yb_ash_fdw() 
;

