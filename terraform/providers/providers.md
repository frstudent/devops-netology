# Решение домашнего задание к занятию "7.6. Написание собственных провайдеров для Terraform."
> Найдите, где перечислены все доступные resource и data_source, приложите ссылку на эти строки в коде на гитхабе.

Но там 1074 файла.
```bash
#!/bin/sh

AWS_SOURCE=~/terraform/aws_provider

FILES=`ls "$AWS_SOURCE/terraform-provider-aws/aws/" | grep -e '^resource' -e '^data_source' | grep -v "test."`
for source in ${FILES}
do
   line=`cat "$AWS_SOURCE/terraform-provider-aws/aws/$source" | grep -n 'Schema:' | awk '{print $1}' FS=":" | head -n1`
   echo  "https://github.com/hashicorp/terraform-provider-aws/blob/main/aws/$source#L$line"
done
```

Вот этот скрпит сгенерирует 1024 ссылки на все доступные resource и data_source

> Для создания очереди сообщений SQS используется ресурс aws_sqs_queue у которого есть параметр name. С каким другим параметром конфликтует name? Приложите строчку кода, в которой это указано.

Параметр name конфликтует с параметром name_prexix
```golang
                "name": {
                        Type:          schema.TypeString,
                        Optional:      true,
                        Computed:      true,
                        ForceNew:      true,
                        ConflictsWith: []string{"name_prefix"},
                },

                "name_prefix": {
                        Type:          schema.TypeString,
                        Optional:      true,
                        Computed:      true,
                        ForceNew:      true,
                        ConflictsWith: []string{"name"},
                },

```

> Какая максимальная длина имени?

80 символов. Если установлен атрибут fifoQueue, то максимальная длина имении 75 символов.

> Какому регулярному выражению должно подчиняться имя?

Cимволы латинского алфавита в верхнем и нижнем регистраз, цифры, подчёркивание, тире разрешены в имени.

```golang
                if fifoQueue {
                        re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,75}\.fifo$`)
                } else {
                        re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,80}$`)
                }

                if !re.MatchString(name) {
                        return fmt.Errorf("invalid queue name: %s", name)
                }

```
