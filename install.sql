drop function if exists yb_ash_fdw;
create function yb_ash_fdw(
 username text default 'yugabyte', password text default 'yugabyte'
) returns table ("__text" text, "__value" text) as $PL$
 declare
  ddl record;
 begin
  execute 'create extension if not exists postgres_fdw';
  for ddl in (
    select format('
     create server if not exists "gv$%1$s"
     foreign data wrapper postgres_fdw
     options (host %2$L, port %3$L, dbname %4$L)
     ', host, host, port, current_database()) as sql
     from yb_servers()
  ) loop
   execute ddl.sql;
  end loop;
  for ddl in (
    select format('
     drop user mapping if exists for admin
     server "gv$%1$s"
     ',host) as sql
     from yb_servers()
  ) loop
   execute ddl.sql;
  end loop;
  for ddl in (
    select format('
     create user mapping if not exists for current_user
     server "gv$%1$s"
     options ( user %2$L, password %3$L )
     ',host, username, password ) as sql
     from yb_servers()
  ) loop
   execute ddl.sql;
  end loop;
  for ddl in (
    select format('
     drop schema if exists "gv$%1$s" cascade
     ',host) as sql
     from yb_servers()
  ) loop
   execute ddl.sql;
  end loop;
  for ddl in (
    select format('
     create schema if not exists "gv$%1$s"
     ',host) as sql
     from yb_servers()
  ) loop
   execute ddl.sql;
  end loop;
  for ddl in (
    select format('
     import foreign schema "pg_catalog"
     limit to ("yb_active_session_history","pg_stat_statements")
     from server "gv$%1$s" into "gv$%1$s"
     ', host) as sql from yb_servers()
  ) loop
   execute ddl.sql;
  end loop;
  for ddl in (
    with views as (
    select distinct foreign_table_name
    from information_schema.foreign_tables t, yb_servers() s
    where foreign_table_schema = format('gv$%1$s',s.host)
    )
    select format('drop view if exists "gv$%1$s"', foreign_table_name) as sql from views
    union all
    select format('create view public."gv$%2$s" as %1$s',
     string_agg(
     format('
     select %2$L as gv$host, %3$L as gv$zone, %4$L as gv$region, %5$L as gv$cloud,
     * from "gv$%2$s".%1$I
     ', foreign_table_name, host, zone, region, cloud)
     ,' union all '), foreign_table_name
    ) from views, yb_servers() group by views.foreign_table_name
  ) loop
   execute ddl.sql;
  end loop;
  return query select distinct format('%s.%s.%s %s',gv$cloud,gv$region,gv$zone,gv$host) as "__text" , gv$host as "__value" from gv$yb_active_session_history;
 end;
$PL$ language plpgsql;