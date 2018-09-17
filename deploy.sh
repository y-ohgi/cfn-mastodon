#!/bin/bash

STACK_NAME="mastodon"
STACK_ROLE=$1

cat <<EOL
> aws cloudformation deploy \\
    --capabilities CAPABILITY_NAMED_IAM \\
    --stack-name ${STACK_NAME}-${STACK_ROLE} \\
    --template-file ./templates/${STACK_ROLE}.yaml \\
    --parameter-overrides StackName=${STACK_NAME}
EOL

aws cloudformation deploy \
    --capabilities CAPABILITY_NAMED_IAM \
    --stack-name ${STACK_NAME}-${STACK_ROLE} \
    --template-file ./templates/${STACK_ROLE}.yaml \
    --parameter-overrides StackName=${STACK_NAME}
