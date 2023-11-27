#!/bin/bash

NAMES=$@
INSTANCE_TYPE=""
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-066e77f4c76020ae9
DOMAIN_NAME=mnyeruva.online

# mysql or mongodb instance typr should br t3.medium

for i in $@
do
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t2.micro"    
    fi    
    echo "creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type $INSTANCE_TYPE  --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instance: $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id Z00388491P1FW72F82KF --change-batch '
    {
            "Comment": "CREATE/DELETE/UPSERT a record ",
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                    "Name": "'$i.$DOMAIN_NAME'",
                                    "Type": "A",
                                    "TTL": 300,
                                 "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
    }}]
    }'
done