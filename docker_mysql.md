# Домашнее задание к занятию "6.3. MySQL"

## Установка docker контейнера  mysql

Текущая конфигурация контейнера создана на основе последующих задач. 
Корректная работа других задач при изменении конфигурации не гарантируется.
Скрипт для подготовки и старта контейнера
_$ cat mysql.sh_

```bash
mkdir /var/mys_data /var/mys_backup /var/mys_custom
chmod 0777 /var/mys_data /var/mys_backup /var/mys_custom
wget -o /var/msys_data/test_dump.sql \
    https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-03-mysql/test_data/test_dump.sql
docker run --name mys  -p3306:3306 \
    -v /var/mys_data:/var/lib/mysql \
    -v /var/mys_backup:/home \
    -v /var/mys_custom:/etc/mysql/conf.d \
    -e MYSQL_ROOT_PASSWORD=pass \
    -d mysql:8 \
    mysqld --default-authentication-plugin=mysql_native_password --pid-file=/var/lib/mysql/mysqld.pid
```

Проверка успешной установки послердством утилиты mysql в контейнере
```bash
docker exec -it mys mysql -uroot -p
```
Не ошибаемся с паролем (в этом задании пароль: pass)  
И видим следующий экран

<pre>
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 20
Server version: 8.0.25 MySQL Community Server - GPL

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
create database mydigits;
</pre>

Создание базы данных задания

```sql
mysql> create database mydigits;
mysql>\q
```

Получен локальный доступ с правами администратора и создана новая база в созданном контейнере.  
Выход из утрилиты и контейнера. 
Далее интерактивный старт bash в контенере
```bash
docker exec -it mys bash
root@99a26f69a799:/# cd /home
root@99a26f69a799:/home# ls
test_dump.sql
root@99a26f69a799:/home# mysql -uroot -p < test_dump.sql
Enter password:
ERROR 1046 (3D000) at line 22: No database selected
```

Исправленный пример восстанволения базы из архивной копии

```bash
root@99a26f69a799:/home# mysql -uroot -p --database=mydigits < test_dump.sql
exit
```
Проверка коректности импорта/восстановлени базы

```bash
root@99a26f69a799:/home# mysql -uroot -p --database=mydigits
```

Проверка результата импорта базы данных
```mysql
mysql> show table status;
mysql> SELECT * FROM information_schema.tables WHERE table_schema = DATABASE();
+---------------+--------------+------------+------------+--------+---------+------------+------------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------------+
| TABLE_CATALOG | TABLE_SCHEMA | TABLE_NAME | TABLE_TYPE | ENGINE | VERSION | ROW_FORMAT | TABLE_ROWS | AVG_ROW_LENGTH | DATA_LENGTH | MAX_DATA_LENGTH | INDEX_LENGTH | DATA_FREE | AUTO_INCREMENT | CREATE_TIME         | UPDATE_TIME         | CHECK_TIME | TABLE_COLLATION    | CHECKSUM | CREATE_OPTIONS | TABLE_COMMENT |
+---------------+--------------+------------+------------+--------+---------+------------+------------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------------+
| def           | mydigits     | orders     | BASE TABLE | InnoDB |      10 | Dynamic    |          5 |           3276 |       16384 |               0 |            0 |         0 |              6 | 2021-06-12 20:05:32 | 2021-06-12 20:05:35 | NULL       | utf8mb4_0900_ai_ci |     NULL |                |               |
+---------------+--------------+------------+------------+--------+---------+------------+------------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------------+
1 row in set (0.01 sec)
mysql> show tables;
+--------------------+
| Tables_in_mydigits |
+--------------------+
| orders             |
+--------------------+
1 row in set (0.00 sec)
mysql> select * from orders where price > 300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
```
Данные успешно восстановлены из резервной копии.

## Задача №2

Добавление пользователя с ограниченными правами

<pre>
mysql> SELECT * from mysql.user where User="root";
+-----------+------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------+------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------------------+--------------------------+----------------------------+---------------+-------------+-----------------+----------------------+-----------------------+------------------------------------------------------------------------+------------------+-----------------------+-------------------+----------------+------------------+----------------+------------------------+---------------------+--------------------------+-----------------+
| Host      | User | Select_priv | Insert_priv | Update_priv | Delete_priv | Create_priv | Drop_priv | Reload_priv | Shutdown_priv | Process_priv | File_priv | Grant_priv | References_priv | Index_priv | Alter_priv | Show_db_priv | Super_priv | Create_tmp_table_priv | Lock_tables_priv | Execute_priv | Repl_slave_priv | Repl_client_priv | Create_view_priv | Show_view_priv | Create_routine_priv | Alter_routine_priv | Create_user_priv | Event_priv | Trigger_priv | Create_tablespace_priv | ssl_type | ssl_cipher             | x509_issuer              | x509_subject               | max_questions | max_updates | max_connections | max_user_connections | plugin                | authentication_string                                                  | password_expired | password_last_changed | password_lifetime | account_locked | Create_role_priv | Drop_role_priv | Password_reuse_history | Password_reuse_time | Password_require_current | User_attributes |
+-----------+------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------+------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------------------+--------------------------+----------------------------+---------------+-------------+-----------------+----------------------+-----------------------+------------------------------------------------------------------------+------------------+-----------------------+-------------------+----------------+------------------+----------------+------------------------+---------------------+--------------------------+-----------------+
| %         | root | Y           | Y           | Y           | Y           | Y           | Y         | Y           | Y             | Y            | Y         | Y          | Y               | Y          | Y          | Y            | Y          | Y                     | Y                | Y            | Y               | Y                | Y                | Y              | Y                   | Y                  | Y                | Y          | Y            | Y                      |          | NULL                   | NULL                     | NULL                       |             0 |           0 |               0 |                    0 | caching_sha2_password | $A$005|IP,E%3PT9#*P0NcTMKLWM/vwb7QiMchwdPtds.04gwvfQ/34cwAUt0          | N                | 2021-06-12 15:59:24   |              NULL | N              | Y                | Y              |                   NULL |                NULL | NULL                     | NULL            |
| localhost | root | Y           | Y           | Y           | Y           | Y           | Y         | Y           | Y             | Y            | Y         | Y          | Y               | Y          | Y          | Y            | Y          | Y                     | Y                | Y            | Y               | Y                | Y                | Y              | Y                   | Y                  | Y                | Y          | Y            | Y                      |          | NULL                   | NULL                     | NULL                       |             0 |           0 |               0 |                    0 | caching_sha2_password | $A$005$pP}8c(2&&cSoF     fslU17y.xorAMH.BWbtptW8hT8Vw6Yl9/52P2fWOxT9   | N                | 2021-06-12 15:59:24   |              NULL | N              | Y                | Y              |                   NULL |                NULL | NULL                     | NULL            |
+-----------+------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------+------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------------------+--------------------------+----------------------------+---------------+-------------+-----------------+----------------------+-----------------------+------------------------------------------------------------------------+------------------+-----------------------+-------------------+----------------+------------------+----------------+------------------------+---------------------+--------------------------+-----------------+
2 rows in set (0.00 sec)

mysql> CREATE USER 'test'
    ->   IDENTIFIED WITH mysql_native_password BY 'test-pass'
    ->   REQUIRE X509 WITH
    MAX_QUERIES_PER_HOUR 60
    PASSWORD EXPIRE INTERVAL 180 DAY
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 2
  ATTRIBUTE '{"fname": "James", "lname": "Pretty", "phone": "800-000-0000"}';
  REQUIRE X509 WITH
    ->     MAX_QUERIES_PER_HOUR 60
    ->     PASSWORD EXPIRE INTERVAL 180 DAY
    ->     FAILED_LOGIN_ATTEMPTS 3
    ->     PASSWORD_LOCK_TIME 2
    ->   ATTRIBUTE '{"fname": "James", "lname": "Pretty", "phone": "800-000-0000"}';
Query OK, 0 rows affected (0.14 sec)

mysql> grant select on mydigits.* to 'test';
Query OK, 0 rows affected (0.32 sec)

mysql> SELECT * from mysql.user where User="test";
+------+------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------+------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------------------+--------------------------+----------------------------+---------------+-------------+-----------------+----------------------+-----------------------+-------------------------------------------+------------------+-----------------------+-------------------+----------------+------------------+----------------+------------------------+---------------------+--------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Host | User | Select_priv | Insert_priv | Update_priv | Delete_priv | Create_priv | Drop_priv | Reload_priv | Shutdown_priv | Process_priv | File_priv | Grant_priv | References_priv | Index_priv | Alter_priv | Show_db_priv | Super_priv | Create_tmp_table_priv | Lock_tables_priv | Execute_priv | Repl_slave_priv | Repl_client_priv | Create_view_priv | Show_view_priv | Create_routine_priv | Alter_routine_priv | Create_user_priv | Event_priv | Trigger_priv | Create_tablespace_priv | ssl_type | ssl_cipher             | x509_issuer              | x509_subject               | max_questions | max_updates | max_connections | max_user_connections | plugin                | authentication_string                     | password_expired | password_last_changed | password_lifetime | account_locked | Create_role_priv | Drop_role_priv | Password_reuse_history | Password_reuse_time | Password_require_current | User_attributes                                                                                                                                              |
+------+------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------+------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------------------+--------------------------+----------------------------+---------------+-------------+-----------------+----------------------+-----------------------+-------------------------------------------+------------------+-----------------------+-------------------+----------------+------------------+----------------+------------------------+---------------------+--------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
| %    | test | N           | N           | N           | N           | N           | N         | N           | N             | N            | N         | N          | N               | N          | N          | N            | N          | N                     | N                | N            | N               | N                | N                | N              | N                   | N                  | N                | N          | N            | N                      | X509     | NULL                   | NULL                     | NULL                       |            60 |           0 |               0 |                    0 | mysql_native_password | *62C4834A52EB88A9E3EBA2EFF227C58AD0248317 | N                | 2021-06-12 21:56:52   |               180 | N              | N                | N              |                   NULL |                NULL | NULL                     | {"metadata": {"fname": "James", "lname": "Pretty", "phone": "800-000-0000"}, "Password_locking": {"failed_login_attempts": 3, "password_lock_time_days": 2}} |
+------+------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------+------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------------------+--------------------------+----------------------------+---------------+-------------+-----------------+----------------------+-----------------------+-------------------------------------------+------------------+-----------------------+-------------------+----------------+------------------+----------------+------------------------+---------------------+--------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

</pre>

## Задача №3

<pre>
mysql> use mydigits;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show table status;
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
| Name   | Engine | Version | Row_format | Rows | Avg_row_length | Data_length | Max_data_length | Index_length | Data_free | Auto_increment | Create_time         | Update_time         | Check_time | Collation          | Checksum | Create_options | Comment |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
| orders | InnoDB |      10 | Dynamic    |    5 |           3276 |       16384 |               0 |            0 |         0 |              6 | 2021-06-12 20:05:32 | 2021-06-12 20:05:35 | NULL       | utf8mb4_0900_ai_ci |     NULL |                |         |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
1 row in set (0.00 sec)
</pre>

Замена движка таблицы

<pre>
mysql> ALTER TABLE `orders` ENGINE=MyISAM;
Query OK, 5 rows affected (2.97 sec)
Records: 5  Duplicates: 0  Warnings: 0


mysql> select * from orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.00 sec)

mysql> show profiles;
+----------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                                                                                                                                                                                  |
+----------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|       10 | 0.00065725 | select * from orders                                                                                                                                                                                                                                                   |
|       11 | 0.00268550 | show table status                                                                                                                                                                                                                                                      |
|       12 | 0.00025975 | commit                                                                                                                                                                                                                                                                 |
|       13 | 0.00290925 | show table status                                                                                                                                                                                                                                                      |
|       14 | 0.00028225 | SET @DATABASE_NAME = 'mydigits'                                                                                                                                                                                                                                        |
|       15 | 0.00225625 | SELECT  CONCAT('ALTER TABLE `', table_name, '` ENGINE=MyISAM;') AS sql_statements
|       16 | 0.00263250 | show table status                                                                                                                                                                                                                                                      |
|       17 | 0.00229575 | show tables                                                                                                                                                                                                                                                            |
|       18 | 0.00027300 | SET @DATABASE_NAME = 'mydigits'                                                                                                                                                                                                                                        |
|       19 | 0.00241450 | SELECT  CONCAT('ALTER TABLE `', table_name, '` ENGINE=MyISAM;') AS sql_statements
|       20 | 0.00228325 | SELECT  CONCAT('ALTER TABLE `', table_name, '` ENGINE=MyISAM;') AS sql_statements   FROM    information_schema.tables AS tb   WHERE   table_schema = @DATABASE_NAME     AND     `ENGINE` = 'InnoDB'     AND     `TABLE_TYPE` = 'BASE TABLE'   ORDER BY table_name DESC |
|       21 | 0.00231200 | SELECT  CONCAT('ALTER TABLE `', table_name, '` ENGINE=MyISAM;') AS sql_statements   FROM    information_schema.tables AS tb   WHERE   table_schema = @DATABASE_NAME     AND     `ENGINE` = 'InnoDB'     AND     `TABLE_TYPE` = 'BASE TABLE'   ORDER BY table_name DESC |
|       22 | 2.96768925 | ALTER TABLE `orders` ENGINE=MyISAM                                                                                                                                                                                                                                     |
|       23 | 0.00347800 | show table status                                                                                                                                                                                                                                                      |
|       24 | 0.00064875 | select * from orders                                                                                                                                                                                                                                                   |
+----------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
15 rows in set, 1 warning (0.00 sec)
</pre>

Как видно из примерв, время выборки данных не изменилось после смены движка.
Объясняется это очень просто, сработали три фактора: 
1. Таблица очень маленькая и простая.
2. Запрос примитивный.
3. Отсутствие нагрузки.

Вернуть движок InnoDB
```sql
SELECT CONCAT('ALTER TABLE ',table_schema,'.',table_name,' engine=InnoDB;') 
  FROM information_schema.tables 
  WHERE engine = 'MyISAM';

ALTER TABLE mydigits.orders engine=InnoDB;
```

## Задача №4

Содержимое файла /var/mys/custom/netology.cnf
При создании контейнера директория монтируеся в локальный volume
<pre>
[mysqld]

port=3306

# key_buffer_size=16M
# max_allowed_packet=128M

# https://www.google.com/search?q=innodb+buffer+pool+size
# https://www.google.com/search?q=innodb+log+file+size+mysql
# https://www.google.com/search?q=innodb+buffer+log+size

innodb_buffer_pool_size=128M
innodb_log_file_size=96M
innodb_log_buffer_size=100M
innodb_file_per_table
innodb_flush_method=O_DIRECT
</pre>

Проверка установленных переменных после пересоздания контейнера

```sql
SHOW VARIABLES WHERE 
  Variable_Name LIKE 'innodb_buffer_pool_size' OR 
  Variable_Name LIKE 'innodb_log_file_size' OR
  Variable_Name LIKE 'innodb_log_buffer_size' OR
  Variable_Name LIKE 'innodb_file_per_table' OR
  Variable_Name LIKE 'innodb_flush_method';
```
<pre>
+-------------------------+-----------+
| Variable_name           | Value     |
+-------------------------+-----------+
| innodb_buffer_pool_size | 134217728 |
| innodb_file_per_table   | ON        |
| innodb_flush_method     | O_DIRECT  |
| innodb_log_buffer_size  | 104857600 |
| innodb_log_file_size    | 100663296 |
+-------------------------+-----------+
5 rows in set (0.00 sec)
</pre>