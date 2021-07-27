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
В задании предлагается использовать блокировку ресурсов с помощью DynamoDB. Terraform import отказывался работать без создания таблицы. Пришлось в WEB-интерфейса создать таблицу frstudent-tf-locks и после этого terraform зврвботвл.

Результат terraform state pull - [resources.yml](resources.yml)

## Инициализируем проект и создаем воркспейсы.

> Вывод команды terraform workspace list.

  default
  prod
* stage

> Вывод команды terraform plan для воркспейса prod.

Ещё одна ночь понадобится. Пока что plan не сработал:
<pre>
Acquiring state lock. This may take a few moments...
Releasing state lock. This may take a few moments...
╷
│ Error: Missing required argument
│
│   with aws_instance.debian,
│   on main.tf line 28, in resource "aws_instance" "debian":
│   28: resource "aws_instance" "debian" {
│
│ "instance_type": one of `instance_type,launch_template` must be specified
╵
╷
│ Error: Missing required argument
│
│   with aws_instance.debian,
│   on main.tf line 28, in resource "aws_instance" "debian":
│   28: resource "aws_instance" "debian" {
│
│ "launch_template": one of `ami,instance_type,launch_template` must be specified
╵
╷
│ Error: Missing required argument
│
│   with aws_instance.debian,
│   on main.tf line 28, in resource "aws_instance" "debian":
│   28: resource "aws_instance" "debian" {
│
│ "ami": one of `ami,launch_template` must be specified
╵
</pre>
