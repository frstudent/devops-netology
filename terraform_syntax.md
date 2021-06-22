# 7.2. Облачные провайдеры и синтаксис Терраформ.

## Задача 1.

> В виде результата задания приложите вывод команды aws configure list.

<pre>
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                  student           manual    --profile
access_key     ****************RAOM shared-credentials-file
secret_key     ****************0ldT shared-credentials-file
    region                us-east-2      config-file    ~/.aws/config
</pre>

Выввод ```aws ec2 describe-instances --profile student``` приводить не буду, поскольку там "sensitive" информация.


## Задача 2.

>  при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?

На занятии речь шла об инструменте Packer от HashiCorp.

> Ссылку на репозиторий с исходной конфигурацией терраформа.

Пока знакомился с возможностями terraform, я создал несколько конфигураций. Привожу ссылку на файлы конфигурации из задания:  

https://github.com/frstudent/devops-netology/tree/main/terraform/homework

Ниже конфигунация на основе [fake-web-services](https://app.terraform.io/fake-web-services) которая использовалась при знакомстве с terraform.


### main.ft

[Основной файл конфигурации](terraform/main.tf)

### backend.ft

[Конфигурация бэкенда](terraform/backend.tf)

### provider.ft

[Настройка провайдера](terraform/provider.tf)

