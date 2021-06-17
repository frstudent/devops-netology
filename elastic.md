# Elastic

## Задача 0  

Подговтока к выпылонению заданий - настройка elasticsearch
```bash
grep -v '^#' elasticsearch.yml
```
<pre>
cluster.name: netology
node.name: netology_test-1

path.data: /var/lib/elastic
path.repo: /var/lib/elastic/shapshots
network.host: 192.168.1.194
http.port: 9200

cluster.initial_master_nodes: ["netology_test-1"]
</pre>

```bash
grep -v '^#' jvm.options
```
<pre>
-Xms2g
-Xmx2g

8-13:-XX:+UseConcMarkSweepGC
8-13:-XX:CMSInitiatingOccupancyFraction=75
8-13:-XX:+UseCMSInitiatingOccupancyOnly

14-:-XX:+UseG1GC

-Djava.io.tmpdir=${ES_TMPDIR}

-XX:+HeapDumpOnOutOfMemoryError

-XX:HeapDumpPath=data

-XX:ErrorFile=logs/hs_err_pid%p.log

8:-XX:+PrintGCDetails
8:-XX:+PrintGCDateStamps
8:-XX:+PrintTenuringDistribution
8:-XX:+PrintGCApplicationStoppedTime
8:-Xloggc:logs/gc.log
8:-XX:+UseGCLogFileRotation
8:-XX:NumberOfGCLogFiles=32
8:-XX:GCLogFileSize=64m

9-:-Xlog:gc*,gc+age=trace,safepoint:file=logs/gc.log:utctime,pid,tags:filecount=32,filesize=64m
</pre>



## Задача 1

Размещение сервиса в контейнере гораздо проще, если вы знакомы с сервисом. 
Поэтому перед помещением сервиса в контейнео предлагаю развернуть, настроить и выполнить выполнить локально. Состояние 



Подготовка docker.compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Содержимое файла Dockerfile

<pre>
FROM centos:7
ENV container docker

RUN sysctl -w vm.max_map_count=262144
RUN sysctl -p

# Install
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.13.2-linux-x86_64.tar.gz
RUN tar xzf elasticsearch-7.13.2-linux-x86_64.tar.gzelasticsearch-7.13.2-linux-x86_64.tar.gz


EXPOSE 9200
</pre>


## Задача 2

```bash
curl -X GET "192.168.1.194:9200/?pretty"
```

<pre>
{
  "name" : "netology_test-1",
  "cluster_name" : "netology",
  "cluster_uuid" : "MP1kw_YSSbWpbEHXCId6RQ",
  "version" : {
    "number" : "7.13.2",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "4d960a0733be83dd2543ca018aa4ddc42e956800",
    "build_date" : "2021-06-10T21:01:55.251515791Z",
    "build_snapshot" : false,
    "lucene_version" : "8.8.2",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
</pre>

Для создания индексов используется следущая команда:

```bash
curl -X PUT "192.168.1.194:9200/ind-1?pretty" -H 'Contt-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    }
  }
}
'
```

Результат выполнения команды:

<pre>
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}
</pre>

Аналогично выполняется для ind-1 и ind-2  
Затем проверка созданных индексов


### Получение списка индексов
```bash
curl -X GET "http://192.168.1.194:9200/_cat/indices"
```
В ответе список индексов и их состояние
<pre>
green  open ind-1 Qmowy6dnSGy1T8wlN37Dhg 1 0 0 0 208b 208b
yellow open ind-3 KS9dy5r4Qt2lwh6MtLB3lA 4 2 0 0 832b 832b
yellow open ind-2 exxqw0veS3mSZLe55p0QeA 2 1 0 0 416b 416b
</pre>

> Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Потому что elasticsearch не нашёл других нод. Чтобы перейти в состоянии greee, потребуется поднять и elasticsearch на соответствующих нодах в кластере. 

```bash
curl -X GET "192.168.1.194:9200/_cat/shards"
```

Вывод команды

<pre>
my-index-000001 0 p STARTED    0 208b 192.168.1.194 netology_test-1
my-index-000001 0 r UNASSIGNED
</pre>

Проверка индекса и его состояние

```bash
curl -X GET "192.168.1.194:9200/ind-1?pretty"
```

Ответ сервера

<pre>
{
  "ind-1" : {
    "aliases" : { },
    "mappings" : { },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "1",
        "provided_name" : "ind-1",
        "creation_date" : "1623930827019",
        "number_of_replicas" : "0",
        "uuid" : "Qmowy6dnSGy1T8wlN37Dhg",
        "version" : {
          "created" : "7130299"
        }
      }
    }
  }
}
</pre>

Аналогично для ind-2

<pre>
{
  "ind-2" : {
    "aliases" : { },
    "mappings" : { },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "2",
        "provided_name" : "ind-2",
        "creation_date" : "1623931017843",
        "number_of_replicas" : "1",
        "uuid" : "exxqw0veS3mSZLe55p0QeA",
        "version" : {
          "created" : "7130299"
        }
      }
    }
  }
}
</pre>

Удаление индексов.
```bash
curl -X DELETE "192.168.1.194:9200/ind-3?pretty"
curl -X DELETE "192.168.1.194:9200/ind-2"
curl -X DELETE "192.168.1.194:9200/ind-1"
```
По моим наблюдениям самая актуальная причина деградации данных это нехватка памяти. Java очень прожорлива. Когдя я присутпил к решению задачи, 
то не удалил контейнеры c предыдущих задач - PostgreSQL и MySQL. В результате скорось работы elassticsearch замедлилась на порядки - начиная от времени 
старта и заканчивая задержкой на ответы. После того как увиличил объём доступного ОЗУ, остановив дополнительные контейнеры, скорость работы стала приемлемой.

##  Задача 3

> Приведите в ответе запрос API и результат вызова API для создания репозитория.

Запрос
```bash
curl -X PUT "192.168.1.194:9200/_snapshot/my_repository?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "netology_backup"
  }
}
'
```
Ответ
<pre>
{
  "acknowledged" : true
}
</pre>

> Создайте индекс test с 0 реплик и 1 шардом и приведите в ответе список индексов.

<pre>
green open test ZwYhYFwORWyhuLICvWD8WA 1 0 0 0 208b 208b
</pre>

Создание снапшота

```bash
curl -X PUT "192.168.1.194:9200/_snapshot/my_repository/snapshot_1?wait_for_completion=true&pretty"
```

<pre>
{
  "snapshot" : {
    "snapshot" : "snapshot_1",
    "uuid" : "L6zvavoZStupjYCe7LkWjA",
    "version_id" : 7130299,
    "version" : "7.13.2",
    "indices" : [
      "ind-1"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2021-06-17T14:55:31.771Z",
    "start_time_in_millis" : 1623941731771,
    "end_time" : "2021-06-17T14:55:33.172Z",
    "end_time_in_millis" : 1623941733172,
    "duration_in_millis" : 1401,
    "failures" : [ ],
    "shards" : {
      "total" : 1,
      "failed" : 0,
      "successful" : 1
    },
    "feature_states" : [ ]
  }
}
</pre>

> Приведите в ответе список файлов в директории со snapshotами.

<pre>
/var/lib/elastic/shapshots/netology_backup# ls -la `pwd`
total 84
drwxr-xr-x 3 devops devops  4096 Jun 17 11:49 .
drwxr-xr-x 3 devops devops  4096 Jun 17 11:37 ..
-rw-r--r-- 1 devops devops   860 Jun 17 11:42 index-1
-rw-r--r-- 1 devops devops     8 Jun 17 11:42 index.latest
drwxr-xr-x 4 devops devops  4096 Jun 17 11:42 indices
-rw-r--r-- 1 devops devops 25734 Jun 17 10:55 meta-L6zvavoZStupjYCe7LkWjA.dat
-rw-r--r-- 1 devops devops 25734 Jun 17 11:42 meta-tETryKpESXuAhKAokPTCQA.dat
-rw-r--r-- 1 devops devops   363 Jun 17 10:55 snap-L6zvavoZStupjYCe7LkWjA.dat
-rw-r--r-- 1 devops devops   360 Jun 17 11:42 snap-tETryKpESXuAhKAokPTCQA.dat
r</pre>

> Удалите индекс test и создайте индекс test-2. Приведите в ответе список индексов.

<pre>
green open test-2 yQxXbBpUSOWNPs-YgvYk7w 1 0 0 0 208b 208b
</pre>

> Приведите в ответе запрос к API восстановления и итоговый список индексов.

### Запрос API восстановления
curl -X POST "192.168.1.194:9200/_snapshot/my_repository/snapshot_2/_restore?pretty"

### Список индексов
<pre>
green open test-2 yQxXbBpUSOWNPs-YgvYk7w 1 0 0 0 208b 208b
green open test   CXNIgVuHTAecxXMunmTi0g 1 0 0 0 208b 208b
</pre>

