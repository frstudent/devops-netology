# Troubleshooting

## Задача 1
> напишите список операций, которые вы будете производить для остановки запроса пользователя

Просмотр лога.
Попрошу пример запроса, который подвисает.
Использую профайлер для поиска истоничка проблемы.

> предложите вариант решения проблемы с долгими (зависающими) запросами в MongoDB

Решения зависит от причины зависания. 
1. Добавление памяти ноде, возможно, сменив при этом тарифный план облачного провайдера.
2. Настройка Sharding с разнесением данных по разным нодам.
3. Поиск возможности оптмизации запроса. Возможно с внесением изменений в структуру базы данных.

## Задача 2
>При масштабировании сервиса до N реплик вы увидели, что:

>сначала рост отношения записанных значений к истекшим
>Redis блокирует операции записи

>Как вы думаете, в чем может быть проблема?


## Задача 3

### InterfaceError: (InterfaceError) 2013: Lost connection to MySQL server during query u'SELECT..... '
>Как вы думаете, почему это начало происходить и как локализовать проблему?

С наибольшей долей вероятности проблема аналогична одной из трёх.
https://stackoverflow.com/questions/29488583/is-there-a-mysql-connection-time-limit/29490286  
https://stackoverflow.com/questions/415905/how-to-set-a-maximum-execution-time-for-a-mysql-query  
https://stackoverflow.com/questions/29755228/sqlalchemy-mysql-lost-connection-to-mysql-server-during-query  
Причина обрыва соединения возможно описана 

>Какие пути решения данной проблемы вы можете предложить?

1. Анализ log-файла MySQL на предмет поиска причины обрыва.
2. Проверка конфигурации MySQL. Возможно разрыв инициирован MySQL сервером по причине таймаута.
<pre>
mysql> show variables like '%time%';
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

mysql> show variables like '%buffer%';
+-------------------------------------+----------------+
| Variable_name                       | Value          |
+-------------------------------------+----------------+
| bulk_insert_buffer_size             | 8388608        |
| innodb_buffer_pool_chunk_size       | 134217728      |
| innodb_buffer_pool_dump_at_shutdown | ON             |
| innodb_buffer_pool_dump_now         | OFF            |
| innodb_buffer_pool_dump_pct         | 25             |
| innodb_buffer_pool_filename         | ib_buffer_pool |
| innodb_buffer_pool_in_core_file     | ON             |
| innodb_buffer_pool_instances        | 1              |
| innodb_buffer_pool_load_abort       | OFF            |
| innodb_buffer_pool_load_at_startup  | ON             |
| innodb_buffer_pool_load_now         | OFF            |
| innodb_buffer_pool_size             | 134217728      |
| innodb_change_buffer_max_size       | 25             |
| innodb_change_buffering             | all            |
| innodb_log_buffer_size              | 104857600      |
| innodb_sort_buffer_size             | 1048576        |
| join_buffer_size                    | 262144         |
| key_buffer_size                     | 16777216       |
| myisam_sort_buffer_size             | 8388608        |
| net_buffer_length                   | 16384          |
| preload_buffer_size                 | 32768          |
| read_buffer_size                    | 131072         |
| read_rnd_buffer_size                | 262144         |
| select_into_buffer_size             | 131072         |
| sort_buffer_size                    | 262144         |
| sql_buffer_result                   | OFF            |
+-------------------------------------+----------------+
26 rows in set (0.00 sec)
</pre>

3. Попросить пользователя пример запроса и провести анализ запроса на основе [вот этой статьи](https://mysqlserverteam.com/mysql-explain-analyze/) и прислать вывод.
4. Если MySql работает в конейнере, проверить нет ли лимитов в конфигурации контейнера. 
5. Увеличить размер оперативной памяти узлу с MySQL. Например, перейдя на другой тарифный план облачного провайдера.

## Задача 4

### postmaster invoked oom-killer

>Как вы думаете, что происходит?

Сервер MySQL запросил у ядра операционной системы объём памяти сверху установленного лимита. В следствии этого процесс был 
принудительно завершён "Out-of-Memory киллером".
 
>Как бы вы решили данную проблему?

Предлагаю пять решения в порядке уменьшения приоритета.

1. Увеличить объём ОЗУ у ноды.  
2. Уменьшить максимальное значение размера shared_buffers.  

<pre>
postgres=# select name, setting from pg_settings where name like '%buffer%';
      name      | setting
----------------+---------
 shared_buffers | 16384
 temp_buffers   | 1024
 wal_buffers    | 512
(3 rows)

postgres=# select name, setting from pg_settings where name like '%connections%';
              name              | setting
--------------------------------+---------
 log_connections                | off
 log_disconnections             | off
 max_connections                | 100
 superuser_reserved_connections | 3
(4 rows)
</pre>

3. Предложить пользователям оптмизированный вариант запросов, потребляющий меньше памяти.  
4. Изменить OOM-scrore процесса.

Например, в моём docker-контейнере процесс postgres всегда имеет PID=1, т.е. подменяет собой init  
Можно вручную назначить
```bash
echo -500 > /proc/1/oom_score_adj
```

5. Отключить OOM-killer  

```bash
sysctl -w vm.oom-kill = 0
```

