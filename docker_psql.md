# Задание 6.2 -  докер и sql

## Задача №1

Создание контейнера для posgresql с двумя томами  

```bash
mkdir /var/pg_data
chmod 077 /var/pg_data
mkdir /var/pg_backup
chmod 0777 /var/pg_packup
docker run --name pg -p5432:5432 \
  -e POSTGRES_PASSWORD=pass \
  -v /var/pg_data:/var/lib/postgresql/data \
  -v /var/pg_backup:/home \
   -d postgres
```

## Задача №2

Интерактивный запуск shell в контейнере и старт psql
```bash
docker exec -it pg bash
su postgres
psql
```

Создание базы данных, владельца базы и установка его прав
```sql
create database alman;
create user netology password '123';
grant all on database alman to netology;
\q
```

Вход под пользователем netology. Утилита psql запросит пароль. 

```bash
$ psql -U netology -W alman
```

Создание таблиц из задания
```sql
create table orders ( id serial primary key, item varchar(128), price numeric(6,2) );
create type residence as ( country varchar(32), country_id integer);
create table clients ( id serial primary key, surname varchar(32) not null, locate residence not null, order_id integer references orders(id) not null);
```

### Список баз данных:

```sql
postgres=# \l
```
<pre>
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

### Список таблиц:

```sql
alman=> \dt
 public | clients | table | netology
 public | orders  | table | netology
```

### Описание таблицы clients

```sql
alman=> \d clients
                                       Table "public.clients"
  Column  |         Type          | Collation | Nullable |                  Default
----------+-----------------------+-----------+----------+-------------------------------------------
 id       | integer               |           | not null | nextval('clients_id_seq'::regclass)
 surname  | character varying(32) |           | not null |
 locate   | residence             |           | not null |
 order_id | integer               |           | not null | nextval('clients_order_id_seq'::regclass)
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)

alman=> \d residence
                  Composite type "public.residence"
   Column   |         Type          | Collation | Nullable | Default
------------+-----------------------+-----------+----------+---------
 country    | character varying(32) |           |          |
 country_id | integer               |           |          |
```

### Описание таблицы orders

```sql
alman=> \d orders
                                    Table "public.orders"
 Column |          Type          | Collation | Nullable |              Default
--------+------------------------+-----------+----------+------------------------------------
 id     | integer                |           | not null | nextval('orders_id_seq'::regclass)
 item   | character varying(128) |           |          |
 price  | numeric(6,2)           |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
```

## Создание непривелегированного пользователя:

```sql
create user test_user;
\c alman
grant SELECT,INSERT,UPDATE,DELETE on table orders,clients to test_user;
```

## Список прав на таблицы:

```sql
alman=# SELECT table_name, grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_name='orders' or table_name= 'clients'
order by table_name, grantee;
```
Вывод запроса в консоль  
<pre> 
 table_name |  grantee  | privilege_type
------------+-----------+----------------
 clients    | netology  | INSERT
 clients    | netology  | TRIGGER
 clients    | netology  | REFERENCES
 clients    | netology  | TRUNCATE
 clients    | netology  | DELETE
 clients    | netology  | UPDATE
 clients    | netology  | SELECT
 clients    | test_user | DELETE
 clients    | test_user | INSERT
 clients    | test_user | SELECT
 clients    | test_user | UPDATE
 orders     | netology  | INSERT
 orders     | netology  | TRIGGER
 orders     | netology  | REFERENCES
 orders     | netology  | TRUNCATE
 orders     | netology  | DELETE
 orders     | netology  | UPDATE
 orders     | netology  | SELECT
 orders     | test_user | DELETE
 orders     | test_user | SELECT
 orders     | test_user | UPDATE
 orders     | test_user | INSERT
(22 rows)
</pre>

## Задача №3

### Вставка данных в таблицу orders:

```sql
alman=> insert into orders (item,price) values
alman-> ('Шоколад',10),
alman-> ('Принтер', 3000),
alman-> ('Книга',500),
alman-> ('Монитор', 7000),
alman-> ('Гитара', 4000)
alman-> ;
INSERT 0 5
```

### Проверка добавления данных в таблицу orders:

```sql
alman=> select * from orders;
 id |  item   |  price
----+---------+---------
  1 | Шоколад |   10.00
  2 | Принтер | 3000.00
  3 | Книга   |  500.00
  4 | Монитор | 7000.00
  5 | Гитара  | 4000.00
(5 rows)
```

## Вставка данных в таблицу clients

```sql
alman=> insert into clients (surname, locate, order_id) values
('Иванов Иван Иванович', '("USA", 1)', 1),
('Петров Петр Петрович', '("Canada",1)', 2),
('Иоганн Себастьян Бах', '("Japan",81)', 3),
('Ронни Джеймс Дио',     '("Russia",7)', 4),
('Ritchie Blackmore',    '("Russia",7)', 5)
;
INSERT 0 5
```

### Проверка данных в таблице clients

```sql
alman=> select * from clients;
 id |       surname        |   locate   | order_id
----+----------------------+------------+----------
  1 | Иванов Иван Иванович | (USA,1)    |        1
  2 | Петров Петр Петрович | (Canada,1) |        2
  3 | Иоганн Себастьян Бах | (Japan,81) |        3
  4 | Ронни Джеймс Дио     | (Russia,7) |        4
  5 | Ritchie Blackmore    | (Russia,7) |        5
(5 rows)
```

## Выбор количества строк в таблицах clients и orders

```sql
alman=> select  (
        select count(*)
        from   clients
        ) as clients_count,
        (
        select count(*)
        from   orders
        ) as order_count;
-- select count(*) from clients;
 clients_count | order_count
---------------+-------------
             5 |           5
(1 row)
```

## Задача №4

### Добавление покупок

```sql
alman=> INSERT INTO clients (surname, locate, order_id ) VALUES
    ( 'Иванов Иван Иванович', '("Ukraine", 380)', (SELECT id from orders WHERE item = 'Книга') ),
    ( 'Петров Петр Петрович', '("Belarus", 375)', (SELECT id from orders WHERE item = 'Монитор') ),
    ( 'Иоганн Себастьян Бах', '("Germany", 49)',  (SELECT id from orders WHERE item = 'Гитара') );
```

### А это добавление покупок другим способом
Поскольку задание указывает лишь имена кастомеров, то будем считать их однофамильцами и раскидаем их по миру.
```sql
alman=>  WITH ins (surname, locate, item_name) AS
( VALUES
    ( 'Иванов Иван Иванович', '("Estonia", 372)', 'Книга' ),
    ( 'Петров Петр Петрович', '("Russia", 7)',    'Монитор' ),
    ( 'Иоганн Себастьян Бах', '("France",  33)',  'Гитара' )
)
INSERT INTO clients
   (surname, locate, order_id)
SELECT
    surname, CAST(locate as residence), id
FROM
  orders JOIN ins
    ON ins.item_name = orders.item ;

```

### А теперь проверка что всё вставлось как надо

```sql
SELECT
  clients.id, clients.surname, clients.locate, orders.item, orders.price
FROM clients
  INNER JOIN orders
    ON clients.order_id = orders.id ;
```

<pre>
 id |       surname        |    locate     |  item   |  price
----+----------------------+---------------+---------+---------
  1 | Иванов Иван Иванович | (USA,1)       | Шоколад |   10.00
  2 | Петров Петр Петрович | (Canada,1)    | Принтер | 3000.00
  3 | Иоганн Себастьян Бах | (Japan,81)    | Книга   |  500.00
  4 | Ронни Джеймс Дио     | (Russia,7)    | Монитор | 7000.00
  5 | Ritchie Blackmore    | (Russia,7)    | Гитара  | 4000.00
  6 | Иванов Иван Иванович | (Ukraine,380) | Книга   |  500.00
  7 | Петров Петр Петрович | (Belarus,375) | Монитор | 7000.00
  8 | Иоганн Себастьян Бах | (Germany,49)  | Гитара  | 4000.00
  9 | Иванов Иван Иванович | (Estonia,372) | Книга   |  500.00
 10 | Петров Петр Петрович | (Russia,7)    | Монитор | 7000.00
 11 | Иоганн Себастьян Бах | (France,33)   | Гитара  | 4000.00
(11 rows)
</pre>

## Задача №5

### Анализ выполнения запроса
```sql
explain analyze 
SELECT
  clients.id, clients.surname, clients.locate, orders.item, orders.price
FROM clients
  INNER JOIN orders
    ON clients.order_id = orders.id ;
```

Результат выполнения звпроса:  
<pre>
                                                   QUERY PLAN
-----------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=15.62..32.46 rows=540 width=406) (actual time=0.092..0.103 rows=11 loops=1)
   Hash Cond: (clients.order_id = orders.id)
   ->  Seq Scan on clients  (cost=0.00..15.40 rows=540 width=122) (actual time=0.022..0.024 rows=11 loops=1)
   ->  Hash  (cost=12.50..12.50 rows=250 width=292) (actual time=0.024..0.025 rows=5 loops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         ->  Seq Scan on orders  (cost=0.00..12.50 rows=250 width=292) (actual time=0.013..0.016 rows=5 loops=1)
 Planning Time: 0.218 ms
 Execution Time: 0.151 ms
(8 rows)
</pre>

Из вывода explain analyze можно судить судить о времени запроса. Я полностью не уверен, однако могу предположить что
здесь показаны три операции и затраченное время, снизу вверх - выборка данных из таблицы orders, время слияние таблиц clients и оrders, 
выборка таблицы clients. Если бы мне потребовалось оптимизировать запрос, я бы его менял и оценивал результат вывода.

## Задача 6

Бэкап базы данных:  
```bash
pg_dump -U netology -W -F t alman | gzip > backup_file.tar.gz
```

Создание нового контейнера. Поскольку задание учебное, volume для данных не поднимаю
```bash
docker stop pg
docker run --name pg2 -p5432:5432 \
  -e POSTGRES_PASSWORD=pass \
  -v /var/pg_backup:/home \
   -d postgres
root@frcloud4:~# docker ps -a
```
<pre>
CONTAINER ID   IMAGE      COMMAND                  CREATED          STATUS                          PORTS                                       NAMES
d2e296633317   postgres   "docker-entrypoint.s…"   18 seconds ago   Up 14 seconds                   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   pg2
c0a94e3b9a03   postgres   "docker-entrypoint.s…"   13 hours ago     Exited (0) About a minute ago                                               pg
</pre>

```bash
docker exec -it pg2 bash
psql -U netology -W alman
```
<pre>
Password:
psql: error: FATAL:  role "netology" does not exist```
</pre>

Восстановление базы данных из бэкапа  
```bash
cd /home
createdb alman
gzip -dc backup_file.tar.gz | pg_restore -C --dbname alman -v
psql -U netology -W alman
```

Судя по логу (ключ -v) база данных восстановилась во вновь созданном контейнере. Но проверить не помешат:
<pre>
postgres@d2e296633317:/home$ psql -U netology -W alman
Password:
psql (13.3 (Debian 13.3-1.pgdg100+1))
Type "help" for help.

alman=> \c alman
Password:
You are now connected to database "alman" as user "netology".
alman=> \dt
          List of relations
 Schema |  Name   | Type  |  Owner
--------+---------+-------+----------
 public | clients | table | netology
 public | orders  | table | netology
(2 rows)

alman=> SELECT
alman->   clients.id, clients.surname, clients.locate, orders.item, orders.price
alman-> FROM clients
alman->   INNER JOIN orders
alman->     ON clients.order_id = orders.id ;
 id |       surname        |    locate     |  item   |  price
----+----------------------+---------------+---------+---------
  1 | Иванов Иван Иванович | (USA,1)       | Шоколад |   10.00
  2 | Петров Петр Петрович | (Canada,1)    | Принтер | 3000.00
  3 | Иоганн Себастьян Бах | (Japan,81)    | Книга   |  500.00
  4 | Ронни Джеймс Дио     | (Russia,7)    | Монитор | 7000.00
  5 | Ritchie Blackmore    | (Russia,7)    | Гитара  | 4000.00
  6 | Иванов Иван Иванович | (Ukraine,380) | Книга   |  500.00
  7 | Петров Петр Петрович | (Belarus,375) | Монитор | 7000.00
  8 | Иоганн Себастьян Бах | (Germany,49)  | Гитара  | 4000.00
  9 | Иванов Иван Иванович | (Estonia,372) | Книга   |  500.00
 10 | Петров Петр Петрович | (Russia,7)    | Монитор | 7000.00
 11 | Иоганн Себастьян Бах | (France,33)   | Гитара  | 4000.00
(11 rows)

alman=>
</pre>

Ура! База данных восстановилась из бэкапа!
