# Домашнее задание к занятию "6.3. MySQL"

## Установка docker контейнера  mysql

Обязательно выбирите версию 8. У меня были проблемы со стартом на latest версии.
```bash
docker run --name mys  -p3306:3306 \
    -v /var/mys_data:/var/lib/mysql \
    -v /var/mys_backup:/home \
    -e MYSQL_ROOT_PASSWORD=pass \
    -d mysql:8
```

И сразу же проверяем успешность установки, запустив интерактивную консольную утилиту в контейнере
```bash
docker exec -it mys mysql -uroot -p
```
Не ошибаемся с паролем (в этом задании пароль - pass)  
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

mysql>
</pre>

Мы получили локальный доступ администратора к базе данных MySQL в контейнере.  
Выходим из утрилиты и выходим контейнера. 

## Задача №2
Меняем рабочую директорию и скачиваем демо-базу. 

```bash
cd /var/mys_backup
wget https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-03-mysql/test_data/test_dump.sql
```

Скачивается дамп демо-базы
<pre>
root@frcloud4:/var/mys_backup# 
--2021-06-12 13:54:16--  https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-03-mysql/test_data/test_dump.sql
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 185.199.110.133, 185.199.109.133, 185.199.108.133, ...
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|185.199.110.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2073 (2.0K) [text/plain]
Saving to: ‘test_dump.sql’

test_dump.sql                                   100%[===================================================>]   2.02K  --.-KB/s    in 0s

2021-06-12 13:54:16 (17.3 MB/s) - ‘test_dump.sql’ saved [2073/2073]

FINISHED --2021-06-12 13:54:16--
Total wall clock time: 0.6s
Downloaded: 1 files, 2.0K in 0s (17.3 MB/s)
</pre>

Наступило время поработать в контейнере
```bash
/var/mys_backup# docker exec -it mys bash
root@99a26f69a799:/#
root@99a26f69a799:/# cd /home
root@99a26f69a799:/home# ls
test_dump.sql
root@99a26f69a799:/home# mysql -uroot -p < test_dump.sql
Enter password:
ERROR 1046 (3D000) at line 22: No database selected
```

Первый комом. Бывает. Пробуем добавить аргемент

<pre>

mysql> create database mydigits;
\q

/home# mysql -uroot -p --database=mydigits
mysql> use mydigits;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A
                   root@99a26f69a799:/home# mysql -uroot -p --database=mydigits < test_dump.sql
Enter password:

/home# mysql -uroot -p --database=mydigits

mysql> show tables;
+--------------------+
| Tables_in_mydigits |
+--------------------+
| orders             |
+--------------------+
1 row in set (0.00 sec)

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

mysql> show table status;

mysql> SELECT * FROM information_schema.tables WHERE table_schema = DATABASE();
+---------------+--------------+------------+------------+--------+---------+------------+------------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------------+
| TABLE_CATALOG | TABLE_SCHEMA | TABLE_NAME | TABLE_TYPE | ENGINE | VERSION | ROW_FORMAT | TABLE_ROWS | AVG_ROW_LENGTH | DATA_LENGTH | MAX_DATA_LENGTH | INDEX_LENGTH | DATA_FREE | AUTO_INCREMENT | CREATE_TIME         | UPDATE_TIME         | CHECK_TIME | TABLE_COLLATION    | CHECKSUM | CREATE_OPTIONS | TABLE_COMMENT |
+---------------+--------------+------------+------------+--------+---------+------------+------------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------------+
| def           | mydigits     | orders     | BASE TABLE | InnoDB |      10 | Dynamic    |          5 |           3276 |       16384 |               0 |            0 |         0 |              6 | 2021-06-12 20:05:32 | 2021-06-12 20:05:35 | NULL       | utf8mb4_0900_ai_ci |     NULL |                |               |
+---------------+--------------+------------+------------+--------+---------+------------+------------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------------+
1 row in set (0.01 sec)

</pre>

