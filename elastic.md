# Elastic

## ������ 1

���������� docker.compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

<pre>
RUN sysctl -w vm.max_map_count=262144
RUN sysctl -p

EXPOSE 9200
</pre>


## ������ 2

<pre>
devops@frcloud4:~/elasticsearch-7.13.2/config$ curl -X GET "192.168.1.194:9200/?pretty"
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

��� �������� �������� ������������ �������� �������:

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

�������� ���������� �������:

<pre>
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}
</pre>

���������� ����������� ��� ind-1 � ind-2  
����� �������� ��������� ��������

```bash
curl -X GET "http://192.168.1.194:9200/_cat/indices"
```
� ������ ������ �������� � �� ���������
<pre>
green  open ind-1 Qmowy6dnSGy1T8wlN37Dhg 1 0 0 0 208b 208b
yellow open ind-3 KS9dy5r4Qt2lwh6MtLB3lA 4 2 0 0 832b 832b
yellow open ind-2 exxqw0veS3mSZLe55p0QeA 2 1 0 0 416b 416b
</pre>

> ��� �� �������, ������ ����� �������� � ������� ��������� � ��������� yellow?

������ ��� elasticsearch �� ������ ������ ���. ����� ������� � ��������� greee, ����������� ������� � elasticsearch �� ��������������� ����� � ��������. 

<pre>
curl -X GET "192.168.1.194:9200/_cat/indices"
yellow open my-index-000001 jw5UEVySQcm4djCbn9T0jw 1 1 0 0 208b 208b
curl -X GET "192.168.1.194:9200/_cat/shards?pretty"
my-index-000001 0 p STARTED    0 208b 192.168.1.194 netology_test-1
my-index-000001 0 r UNASSIGNED
</pre>

�������� ������� � ��� ���������

```bash
curl -X GET "192.168.1.194:9200/ind-1?pretty"
```

����� �������
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

���������� ��� ind-2
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

�������� ��������.
```bash
curl -X DELETE "192.168.1.194:9200/ind-3?pretty"
curl -X DELETE "192.168.1.194:9200/ind-2"
curl -X DELETE "192.168.1.194:9200/ind-1"
```
�� ���� ����������� ����� ���������� ������� ���������� ������ ��� �������� ������. Java ����� ����������. ����� � ��������� � ������� ������, 
�� �� ������ ���������� c ���������� ����� - PostgreSQL � MySQL. � ���������� ������� ������ elassticsearch ����������� �� ������� - ������� �� ������� 
������ � ���������� ��������� �� ������. ����� ���� ��� �������� ����� ���������� ���, ��������� �������������� ����������, �������� ������ ����� ����������.

##  ������ 3

