Mastodon Cloudformation
---

# Components
* VPC
* NAT Gateway
* Route53
* ACM
* ALB
* S3
* SES
* RDS Postgres
* ElastiCache Redis
* ECS Fargate

# How to Deploy
## Setup
```
$ cd /path/to/mastodon
$ OTP_SECRET=$(docker-compose run --rm web rake mastodon:webpush:generate_vapid_key)
$ SECRET_KEY_BASE=$(docker-compose run --rm web rake mastodon:webpush:generate_vapid_key)
$ docker-compose run --rm web rake mastodon:webpush:generate_vapid_key
# 出力された値を評価
```

## Deploy
```
$ ./deploy.sh parameters
$ ./deploy.sh network
$ ./deploy.sh securitygroup
$ ./deploy.sh ecs
$ ./deploy.sh redis
$ ./deploy.sh rds DBPassword=/mastodon/db/password
$ ./deploy.sh alb AcmArn=<YOUR ACM ARN>
$ ./deploy.sh ecs
$ ./deploy.sh ecs-service \
    DbPass=/mastodon/db/password \
    OtpSecret=$OTP_SECRET \
    SecretKeyBase=$SECRET_KEY_BASE \
    VapidPrivateKey=$VAPID_PRIVATE_KEY \
    VapidPublicKey=$VAPID_PUBLIC_KEY
    LocalDomain=<YOUR DOMAIN> \
    SmtpFromAddress=<YOUR SMTP ADDRESS> \ #e.g. email-smtp.us-west-2.amazonaws.com
    SmtpLogin=<YOUR IAM USER ACCESS KEY> \
    SmtpPassword=<YOUR IAM USER SECRET KEY>
```

## rakeの実行
`rake` 実行するためにタスク定義を用いる。  
ユースケースとして、 *管理者権限の付与* や *DBのマイグレーション* に用いる。

```
$ TASK_DEFINITION=$(aws ecs list-task-definitions | jq -r '.taskDefinitionArns | .[]' | grep mastodon-web | tail -n 1)
$ SUBNET_IDS=$(aws cloudformation list-exports | jq -r '.Exports[] | select(.Name == "mastodon-PrivateSubnetIds") | .Value')
$ SECURITY_GROUP_ID=$(aws cloudformation list-exports | jq -r '.Exports[] | select(.Name == "mastodon-SecurityGroupEcsServiceMastodon") | .Value')
$ USERNAME=<ADMIN USERNAME>
$ cat <<EOL > overrides.json
{
  "containerOverrides": [
    {
      "name": "web",
      "command": ["rails", "mastodon:make_admin", "USERNAME=${USERNAME}"]
    }
  ]
}
EOL
$ aws ecs run-task \
    --cluster mastodon-cluster \
    --task-definition $TASK_DEFINITION \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_IDS],securityGroups=[$SECURITY_GROUP_ID]}" \
    --overrides file://overrides.json
```
