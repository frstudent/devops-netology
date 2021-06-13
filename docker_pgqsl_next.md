# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача №1

### Создайние и настройка контейнера

```bash
# Create postgres directories for Docker volumes
mkdir /var/pg_data /var/pg_backup /var/pg_backup/in /var/pg_backup/out
chmod 0777 /var/pg_data /var/pg_packup /var/pg_backup/in /var/pg_backup/out

# Download netology task database
wget -P /var/pg_backup/in \
   https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-04-postgresql/test_data/test_dump.sql

# Create and run postgresql container
docker run --name pg -p5432:5432 \
  -e POSTGRES_PASSWORD=pass \
  -v /var/pg_data:/var/lib/postgresql/data \
  -v /var/pg_backup:/home \
   -d postgres

# Run shell in container
docker exec -it pg bash

# Run client
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

## Задача №2

Восстановление базы данных из дампа

```bash
docker exec -it pg bash
root@2f5e8a4857a6:/home/in# su postgres
postgres@2f5e8a4857a6:/home/in$ createdb test_database
postgres@2f5e8a4857a6:/home/in$ cd /home/in
postgres@2f5e8a4857a6:/home/in$ psql test_database < test_dump.sql
postgres@2f5e8a4857a6:/home/in$ psql -W test_database
```

<pre>
test_database=# select * from orders;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  2 | My little database   |   500
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  6 | WAL never lies       |   900
  7 | Me and my bash-pet   |   499
  8 | Dbiezdmin            |   501
(8 rows)
</pre>

Анализ таблицы orders

```sql
test_database=# analyze verbose orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 8 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```	

----

Задание гласит: _"Используя таблицу pg_stats, найдите столбец таблицы orders с наибольшим средним значением размера элементов в байтах."_  
Делаем выборку строк непосредственно из консоли.

```bash
postgres@2f5e8a4857a6:/home/tests$ psql -W test_database -c "SELECT * FROM pg_stats WHERE tablename='orders'"
```

<pre>
Password:
 schemaname | tablename | attname | inherited | null_frac | avg_width | n_distinct | most_common_vals | most_common_freqs |                                                                 histogram_bounds                                                                  | correlation | most_common_elems | most_common_elem_freqs | elem_count_histogram
------------+-----------+---------+-----------+-----------+-----------+------------+------------------+-------------------+---------------------------------------------------------------------------------------------------------------------------------------------------+-------------+-------------------+------------------------+----------------------
 public     | orders    | id      | f         |         0 |         4 |         -1 |                  |                   | {1,2,3,4,5,6,7,8}                                                                                                                                 |           1 |                   |                        |
 public     | orders    | title   | f         |         0 |        16 |         -1 |                  |                   | {"Adventure psql time",Dbiezdmin,"Log gossips","Me and my bash-pet","My little database","Server gravity falls","WAL never lies","War and peace"} |  -0.3809524 |                   |                        |
 public     | orders    | price   | f         |         0 |         4 |     -0.875 | {300}            | {0.25}            | {100,123,499,500,501,900}                                                                                                                         |   0.5952381 |                   |                        |
(3 rows)
</pre>

Как же это интерпетировать?
