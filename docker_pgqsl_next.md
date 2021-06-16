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
postgres@2f5e8a4857a6:/home/in$ psql -W test_database < test_dump.sql
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

Как же это интерпетировать? Вероятно речь идёт о столбце avg_width  

## Задача №3

> провести разбиение таблицы orders на на две  
На видеоуроке с 38-ой минуты

```sql
begin transaction;                                                                  	
CREATE TABLE test_orders (id int, title varchar(80), price integer)  partition by range(price);
CREATE TABLE cheap_orders PARTITION OF test_orders for values from(0) to (500);
CREATE TABLE gross_orders PARTITION OF test_orders for values from (500) to (100000);
INSERT INTO test_orders SELECT * FROM orders;
ALTER TABLE orders RENAME TO deleting_orders;
ALTER TABLE test_orders RENAME TO orders;
DROP TABLE deleting_orders;
commit;
```

Проверка разбиения на партиции.

<pre>
test_database=# \d+ orders
                                 Partitioned table "public.test_orders"
 Column |         Type          | Collation | Nullable | Default | Storage  | Stats target | Description
--------+-----------------------+-----------+----------+---------+----------+--------------+-------------
 id     | integer               |           |          |         | plain    |              |
 title  | character varying(80) |           |          |         | extended |              |
 price  | integer               |           |          |         | plain    |              |
Partition key: RANGE (price)
Partitions: cheap_orders FOR VALUES FROM (0) TO (499),
            gross_orders FOR VALUES FROM (500) TO (100000)

</pre>

> Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?  

Вопрос неоднозначный. Запретить? Если нет, то ответ находится в предыдущем решении - 
если разбить на партиции при проектировании, то не придётся вручную разбивать. 

## Задача №4

```bash
cd /home; pg_dump -U postgres -W test_database > test_database_dump.sql
```

> Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца title для таблиц test_database?

Я бы не стал править бэкап-файл - пусть этим занимаются DBA инженеры.  
По условию задачи база данных активна. Повесить UNIQUE для столбца title через констрейны postgres 8 не позволяет. mysql тоже. 
Происходил конфликт с разбиением на партиции. Вероятно решить эту задачу таким способом можно в коммерческих версиях продуктов. 
Для решения задачи я использовал SQL - вынес поле titles в отдельную таблицу, создал primary key, сделал уникальным поле title.
Затем создал новую таблицу с foreign key и range. Затем создал партиции для дешёвых и дорогих товаров.
В итоге заполнил новую таблицу данными из оригинальной, заменив текстовое поле на индекс.

```sql
begin transaction;                                                                  	
DROP TABLE IF EXISTS titles;
create table titles as 
  select id, title from orders;
alter table titles 
  rename id to title_key;
alter table titles 
  add primary key (title_key);
alter table titles 
  add constraint title_key UNIQUE (title);
create table "fixed_orders" (
  id integer,
  title_key int,
  price integer,
    CONSTRAINT fk_customer
      FOREIGN KEY(title_key)
      REFERENCES my(id)
) PARTITION BY RANGE(price);
CREATE TABLE cheap_orders PARTITION OF "fixed_orders" for values from(0) to (500);
CREATE TABLE gross_orders PARTITION OF "fixed_orders" for values from (500) to (100000);
insert into "fixed_orders" 
  select o.id, t.title_key, o.price 
    from orders o 
    inner join titles t on t.title = o.title
  ;
commit;
```

Проверка трансформации.

```sql
explain select id, t.title, price from fixed_orders as o 
  join titles as t on o.title_key = t.title_key;
```

<pre>
test_database=# explain select  o.id, t.title, price from fixed_orders as o
  join my as t on o.title_key = t.id;
                                     QUERY PLAN
-------------------------------------------------------------------------------------
 Hash Join  (cost=1.18..93.31 rows=163 width=186)
   Hash Cond: (o.title_key = t.id)
   ->  Append  (cost=0.00..81.20 rows=4080 width=12)
         ->  Seq Scan on fix_cheap_orders o_1  (cost=0.00..30.40 rows=2040 width=12)
         ->  Seq Scan on fix_gross_orders o_2  (cost=0.00..30.40 rows=2040 width=12)
   ->  Hash  (cost=1.08..1.08 rows=8 width=182)
         ->  Seq Scan on my t  (cost=0.00..1.08 rows=8 width=182)
(7 rows)

test_database=# select f.id, m.title, f.price from fixed_orders as f join titles as m on f.title_key = m.title_key;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
(8 rows)

test_database=# select f.id, m.title, f.price from fix_cheap_orders as f join titles as m on f.title_key = m.title_key;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)

test_database=# select f.id, m.title, f.price from fix_gross_orders as f join titles as m on f.title_key = m.title_key;
 id |       title        | price
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)

test_database=#
</pre>



<!--
Это пробоба от 15 июнь (06) 2021.

INSERT INTO table_output
SELECT f.*
FROM   "orders" t, my_func(t.id) f;

create table "titles"  as select ("id","title") from "orders";;
insert into "titles" ("id", "title") select ("id","title") from "orders";
create table "fix_orders" (id primary key, "title_ref" REFERENCE titiles (id), price integer ) as select ("id", "title", "price") from "orders" 

CREATE TABLE t1 (
    col1 INT UNIQUE NOT NULL,
    col2 DATE NOT NULL,
    col3 INT NOT NULL,
    col4 INT PIMARY KEY
)
PARTITION BY RANGE(col4);

CREATE TABLE tot (id int primary key, title varchar(80) unique, price integer)  partition by range(price);

create table titles (id int primary key, title varchar(80) unique not null);
CREATE TABLE test_orders (id int, title varchar(80), price integer)  partition by range(price);

CREATE TABLE test_orders (
    order_id integer PRIMARY KEY,
    product_no integer REFERENCES products (product_no),
    price integer
) partition by range(price);


alter table orders add primary key(id, title, price);
alter table orders add unique key(title);

create table "fix_orders" (id primary key, "title_ref" REFERENCE titiles (id), price integer );
 as select ("id", "title", "price") from "orders" 
-->



