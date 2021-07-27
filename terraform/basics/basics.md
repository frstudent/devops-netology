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

Ну что, всппомним стеденческие годы? Сдаю задание и остаётся ночь на выполнение. Надеюсь преподаватель не будет проверять ночью.
К утру тут должно быть решение.

