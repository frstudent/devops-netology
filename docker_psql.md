# ������� �� ������ � sql

```sql
> create database alman;
> create user netology password '123';
> grant all on database alman to netology;
```

$ psql -U netology -W alman

```sql
create table orders ( id serial primary key, item varchar(128), price numeric(6,2) );
create type residence as ( country varchar(32), country_id integer);
create table clients ( id serial primary key, surname varchar(32) not null, locate residence not null, order_id integer references orders(id) not null);
```

## ������ ��� ������:

```shell
postgres=# \l
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
```

## ������ ������:

```sql
alman=> \dt
 public | clients | table | netology
 public | orders  | table | netology
```

### �������� ������� clients

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

## �������� ������� orders

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

## �������� �������������������� ������������:

```sql
create user test_user;
\c alman
grant SELECT,INSERT,UPDATE,DELETE on table orders,clients to test_user;
```

## ������ ���� �� �������:

```sql
alman=# SELECT table_name, grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_name='orders' or table_name= 'clients'
order by table_name, grantee;
```
����� ������� � �������  
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
```
</pre>

### ������� ������ � ������� orders:

```sql
alman=> insert into orders (item,price) values
alman-> ('�������',10),
alman-> ('�������', 3000),
alman-> ('�����',500),
alman-> ('�������', 7000),
alman-> ('������', 4000)
alman-> ;
INSERT 0 5
```

### �������� ���������� ������ � ������� orders:

```sql
alman=> select * from orders;
 id |  item   |  price
----+---------+---------
  1 | ������� |   10.00
  2 | ������� | 3000.00
  3 | �����   |  500.00
  4 | ������� | 7000.00
  5 | ������  | 4000.00
(5 rows)
```

## ������� ������ � ������� clients

```sql
alman=> insert into clients (surname, locate, order_id) values
('������ ���� ��������', '("USA", 1)', 1),
('������ ���� ��������', '("Canada",1)', 2),
('������ ��������� ���', '("Japan",81)', 3),
('����� ������ ���',     '("Russia",7)', 4),
('Ritchie Blackmore',    '("Russia",7)', 5)
;
INSERT 0 5
```

### �������� ������ � ������� clients

```sql
alman=> select * from clients;
 id |       surname        |   locate   | order_id
----+----------------------+------------+----------
  1 | ������ ���� �������� | (USA,1)    |        1
  2 | ������ ���� �������� | (Canada,1) |        2
  3 | ������ ��������� ��� | (Japan,81) |        3
  4 | ����� ������ ���     | (Russia,7) |        4
  5 | Ritchie Blackmore    | (Russia,7) |        5
(5 rows)
```

## ����� ���������� ����� � �������� clients � orders

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

## ���������� �������

```sql
alman=> INSERT INTO clients (surname, locate, order_id ) VALUES
    ( '������ ���� ��������', '("Ukraine", 380)', (SELECT id from orders WHERE item = '�����') ),
    ( '������ ���� ��������', '("Belarus", 375)', (SELECT id from orders WHERE item = '�������') ),
    ( '������ ��������� ���', '("Germany", 49)',  (SELECT id from orders WHERE item = '������') );
```

## � ��� � ���� �� ���������� ����

```sql
alman=>  WITH ins (surname, locate, item_name) AS
( VALUES
    ( '������ ���� ��������', '("Estonia", 372)', '�����' ),
    ( '������ ���� ��������', '("Russia", 7)',    '�������' ),
    ( '������ ��������� ���', '("France",  33)',  '������' )
)
INSERT INTO clients
   (surname, locate, order_id)
SELECT
    surname, CAST(locate as residence), id
FROM
  orders JOIN ins
    ON ins.item_name = orders.item ;

```

## � ������ �������� ��� �� ��������� ��� ����

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
  1 | ������ ���� �������� | (USA,1)       | ������� |   10.00
  2 | ������ ���� �������� | (Canada,1)    | ������� | 3000.00
  3 | ������ ��������� ��� | (Japan,81)    | �����   |  500.00
  4 | ����� ������ ���     | (Russia,7)    | ������� | 7000.00
  5 | Ritchie Blackmore    | (Russia,7)    | ������  | 4000.00
  6 | ������ ���� �������� | (Ukraine,380) | �����   |  500.00
  7 | ������ ���� �������� | (Belarus,375) | ������� | 7000.00
  8 | ������ ��������� ��� | (Germany,49)  | ������  | 4000.00
  9 | ������ ���� �������� | (Estonia,372) | �����   |  500.00
 10 | ������ ���� �������� | (Russia,7)    | ������� | 7000.00
 11 | ������ ��������� ��� | (France,33)   | ������  | 4000.00
(11 rows)
</pre>

