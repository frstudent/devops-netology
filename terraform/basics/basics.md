# 7.3. Основы и принцип работы Терраформ

## Бэкэнд в S3

```
terraform {
  backend "s3" {
    bucket = "frstudentdata"
    key    = "frstudentdata/key"
    region = "us-east-2"
    dynamodb_table = "frstudent-tf-locks"
    encrypt        = true
  }
}
```
В задании предлагается использовать блокировку ресурсов с помощью DynamoDB. Terraform import отказывался работать без создания таблицы. Пришлось в WEB-интерфейса создать таблицу frstudent-tf-locks и после этого terraform зврвботал.

Результат terraform state pull - [resources.yml](resources.yml)

## Инициализируем проект и создаем воркспейсы.

> Вывод команды terraform workspace list.

<pre>
  default
  prod
* stage
</pre>

> Вывод команды terraform plan для воркспейса prod.

```bash
$ terraform workspace select prod
$ terrafrom plan -no-color > plan_output.txt
```

Собственно вывод - [plan_output.txt](plan_output.txt)

Файлы проекта:

[main.tf](main.tf)

[backend.tf](backend.tf)

[versions.td](versions.td)
