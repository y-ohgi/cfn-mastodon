#!/bin/bash

STACK_NAME="mastodon"
STACK_ROLE=$1

cat <<EOL
> aws cloudformation create-change-set \\
    --capabilities CAPABILITY_NAMED_IAM \\
    --stack-name ${STACK_NAME}-${STACK_ROLE} \\
    --change-set-name ${STACK_NAME}-${STACK_ROLE}-$(date "+%Y%m%d-%H%M%S") \\
    --template-file file://templates/${STACK_ROLE}.yaml \\
    --parameters ParameterKey=StackName,ParameterValue=${STACK_NAME} $(echo ${@:2:($#-1)})
EOL

aws cloudformation create-change-set \
    --capabilities CAPABILITY_NAMED_IAM \
    --stack-name ${STACK_NAME}-${STACK_ROLE} \
    --change-set-name ${STACK_NAME}-${STACK_ROLE}-$(date "+%Y%m%d-%H%M%S") \
    --template-body file://templates/${STACK_ROLE}.yaml \
    --parameters "ParameterKey=StackName,ParameterValue=${STACK_NAME} $(echo ${@:2:($#-1)})"
