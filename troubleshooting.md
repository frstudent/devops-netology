# Troubleshooting

## Задача 1
### _"...у него уже 3 минуты происходит CRUD операция в MongoDB и её нужно прервать."_
> напишите список операций, которые вы будете производить для остановки запроса пользователя

Просмотр лога.  
```
db.currentOp().inprog.forEach(
  function(op) {
    if(op.secs_running > 60) printjson(op);
  }
)
```
Вывод:
<pre>
{
    "locks": {"^myDB": "R"},
    "ns": "myDB.bar",
    "op": "query",
    "opid": 1349152,
    "query": {"test": 1},
    "secs_running": 15,
    "waitingForLock": true
  }
</pre>

Остановка зависшего процесса. Аргумент команды "opid" из вывода предыдущей.

```
db.killOp(1344808)
```

> предложите вариант решения проблемы с долгими (зависающими) запросами в MongoDB

Решение зависит от причины зависания. 
1. Добавление памяти ноде, возможно, сменив при этом тарифный план облачного провайдера.
2. Настройка Sharding с разнесением данных по разным нодам.
3. Поиск возможности оптмизации запроса. Возможно с внесением изменений в структуру базы данных.

## Задача 2
>При масштабировании сервиса до N реплик вы увидели, что:
>сначала рост отношения записанных значений к истекшим
>Redis блокирует операции записи
>Как вы думаете, в чем может быть проблема?

<pre>
redis 127.0.0.1:6379> slowlog get 2
1) 1) (integer) 14
   2) (integer) 1309448221
   3) (integer) 15
   4) 1) "ping"
2) 1) (integer) 13
   2) (integer) 1309448128
   3) (integer) 30
   4) 1) "slowlog"
      2) "get"
      3) "100"
</pre>

Вероятно в этот log попадут операции репликации узлов, которые будут блокировать операции записи. 

## Задача 3
### InterfaceError: (InterfaceError) 2013: Lost connection to MySQL server during query u'SELECT..... '
>Как вы думаете, почему это начало происходить и как локализовать проблему?

С наибольшей долей вероятности проблема аналогична одной из трёх:.  
https://stackoverflow.com/questions/29488583/is-there-a-mysql-connection-time-limit/29490286  
https://stackoverflow.com/questions/415905/how-to-set-a-maximum-execution-time-for-a-mysql-query  
https://stackoverflow.com/questions/29755228/sqlalchemy-mysql-lost-connection-to-mysql-server-during-query  

>Какие пути решения данной проблемы вы можете предложить?

1. Анализ log-файла MySQL на предмет поиска причины обрыва.
2. Проверка конфигурации MySQL. Возможно разрыв инициирован MySQL сервером по причине таймаута.
```sql
mysql> show variables like '%time%';
```
<pre>
+-----------------------------------+-------------------+
| Variable_name                     | Value             |
+-----------------------------------+-------------------+
| binlog_max_flush_queue_time       | 0                 |
| connect_timeout                   | 10                |
| default_password_lifetime         | 0                 |
| delayed_insert_timeout            | 300               |
| explicit_defaults_for_timestamp   | ON                |
| flush_time                        | 0                 |
| have_statement_timeout            | YES               |
| innodb_flush_log_at_timeout       | 1                 |
| innodb_lock_wait_timeout          | 50                |
| innodb_old_blocks_time            | 1000              |
| innodb_rollback_on_timeout        | OFF               |
| interactive_timeout               | 28800             |
| lc_time_names                     | en_US             |
| lock_wait_timeout                 | 31536000          |
| log_timestamps                    | UTC               |
| long_query_time                   | 10.000000         |
| max_execution_time                | 0                 |
| mysqlx_connect_timeout            | 30                |
| mysqlx_idle_worker_thread_timeout | 60                |
| mysqlx_interactive_timeout        | 28800             |
| mysqlx_port_open_timeout          | 0                 |
| mysqlx_read_timeout               | 30                |
| mysqlx_wait_timeout               | 28800             |
| mysqlx_write_timeout              | 60                |
| net_read_timeout                  | 30                |
| net_write_timeout                 | 60                |
| original_commit_timestamp         | 36028797018963968 |
| regexp_time_limit                 | 32                |
| rpl_stop_slave_timeout            | 31536000          |
| slave_net_timeout                 | 60                |
| slow_launch_time                  | 2                 |
| system_time_zone                  | UTC               |
| time_zone                         | SYSTEM            |
| timestamp                         | 1624148181.046943 |
| wait_timeout                      | 28800             |
+-----------------------------------+-------------------+
35 rows in set (0.00 sec)
</pre>
Вероятно что некоторые значения были исправилены администратором в сторону уменьшения. Возможно некоторые из них можно слегка увеличить  

3. Попросить пользователя пример запроса и провести анализ запроса на основе [вот этой статьи](https://mysqlserverteam.com/mysql-explain-analyze/) и прислать вывод.  
4. Если MySql работает в конейнере, проверить нет ли лимитов в конфигурации контейнера.  
5. Увеличить размер оперативной памяти узлу с MySQL. Например, перейдя на другой тарифный план облачного провайдера.  

## Задача 4
### postmaster invoked oom-killer
>Как вы думаете, что происходит?

Сервер MySQL запросил у ядра операционной системы объём памяти сверху установленного лимита. В следствии этого процесс был 
принудительно завершён "Out-of-Memory киллером".
 
>Как бы вы решили данную проблему?

Предлагаю нескольско способов в порядке уменьшения приоритета.

1. __Увеличить__ объём ОЗУ у ноды.  
2. __Уменьшить__ максимальное значение размера shared_buffers.  

```sql
postgres=# select name, setting from pg_settings where name like '%buffer%';
```

<pre>
      name      | setting
----------------+---------
 shared_buffers | 16384
 temp_buffers   | 1024
 wal_buffers    | 512
(3 rows)
</pre>

```sql
postgres=# select name, setting from pg_settings where name like '%connections%';
```
<pre>
              name              | setting
--------------------------------+---------
 log_connections                | off
 log_disconnections             | off
 max_connections                | 100
 superuser_reserved_connections | 3
(4 rows)
</pre>

3. Предложить пользователям оптмизированный вариант запросов, потребляющий меньше памяти.  
4. Изменить OOM-score процесса.

Например, в моём docker-контейнере процесс postgres всегда имеет PID=1, т.е. подменяет собой init  
Можно вручную назначить
```bash
echo -500 > /proc/1/oom_score_adj
```

<!--
5. Отключить OOM-killer  

```bash
sysctl -w vm.oom-kill = 0
```
-->

