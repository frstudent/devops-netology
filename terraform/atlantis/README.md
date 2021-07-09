# "7.4. Средства командной работы над инфраструктурой."

## Задача 1. Настроить terraform cloud

Скриншоты выполнения задания

[Команда Plan](Terraform_plan.png)

[Команда Apply](Terraform_apply.png)


## Задача 2. Написать серверный конфиг для атлантиса.

[Файл server.yaml](server.yaml)

[Файл atlantis.yaml](atlantis.yaml)

## Задача 3. Знакомство с каталогом модулей.

> Задумайтесь, будете ли в своем проекте использовать этот модуль или непосредственно ресурс aws_instance без помощи модуля?

В случае простого модуля, такого как aws_instance, я буду использовать непосредственно ресурс.

Модуль https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
