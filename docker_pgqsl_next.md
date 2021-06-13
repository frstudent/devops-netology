# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача №1

```bash
mkdir /var/pg_data /var/pg_backup
chmod 0777 /var/pg_data /var/pg_packup
docker run --name pg -p5432:5432 \
  -e POSTGRES_PASSWORD=pass \
  -v /var/pg_data:/var/lib/postgresql/data \
  -v /var/pg_backup:/home \
   -d postgres

docker exec -it pg bash
su postgres
psql
```

### Получение списка баз данных

<pre>
postgres-# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 alman     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres         +
           |          |          |            |            | postgres=CTc/postgres+
           |          |          |            |            | netology=CTc/postgres
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(4 rows)
</pre>

### Пример подключения к базе данных alman 
(база данных взят из предыдущей домашней работы)

<pre>
postgres-# \c alman
You are now connected to database "alman" as user "postgres".
</pre>

### Вывод списка таблиц

<pre>
alman-# \dt
          List of relations
 Schema |  Name   | Type  |  Owner
--------+---------+-------+----------
 public | clients | table | netology
 public | orders  | table | netology
(2 rows)
</pre>

### Вывод описания содержимого таблиц

<pre>
alman=# \d clients
                                    Table "public.clients"
  Column  |         Type          | Collation | Nullable |               Default
----------+-----------------------+-----------+----------+-------------------------------------
 id       | integer               |           | not null | nextval('clients_id_seq'::regclass)
 surname  | character varying(32) |           | not null |
 locate   | residence             |           | not null |
 order_id | integer               |           | not null |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
</pre>

### Выход из psql
```sql
\q
```
Так же достаточно нажать Ctrl+D для выхода из psql
