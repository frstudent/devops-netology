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

Выввод ```aws ec2 describe-instances --profile student``` приводить не буду, поскольку там "личная" информация.


## Задача 2.

### main.ft

[Основной файл конфигурации](terraform/main.tf)

### backend.ft

[Конфигурация бэкенда](terraform/backend.tf)

### provider.ft

[Настройка провайдера](terraform/provider.tf)

В итоге получилась такая инфраструктура - https://app.terraform.io/fake-web-services
