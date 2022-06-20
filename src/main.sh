#!/bin/bash

SPEC_FILE="spec.yaml"
DEPLOYMENT_FILE="create-deployment.json"

validate_inputs() {
    if [ -z ${INPUT_APPLICATION_NAME} ]; then
        echo "Input application_name cannot be empty."
        exit 1
    

    elif [ -z ${INPUT_BUCKET_NAME} ]; then
        echo "Input bucket_name cannot be empty."
        exit 1
    
    elif [ -z ${INPUT_CONTAINER_NAME} ]; then
        echo "Input container_name cannot be empty."
        exit 1
    
    elif [ -z ${INPUT_CONTAINER_PORT} ]; then
        echo "Input container_port cannot be empty."
        exit 1

    elif [ -z ${INPUT_DEPLOYMENT_GROUP_NAME} ]; then
        echo "Input deployment_group_name cannot be empty."
        exit 1
    
    elif [ -z ${INPUT_REGION} ]; then
        echo "Input region cannot be empty."
        exit 1
    fi

    applicationName=${INPUT_APPLICATION_NAME}
    bucketName=${INPUT_BUCKET_NAME}
    containerName=${INPUT_CONTAINER_NAME}
    containerPort=${INPUT_CONTAINER_PORT}
    deploymentGroupName=${INPUT_DEPLOYMENT_GROUP_NAME}
    region=${INPUT_REGION}
}

get_latest_task_definition(){
    TASK_DEFINITION=$(aws ecs list-task-definitions --region ${region} --family-prefix ${containerName} | jq '.taskDefinitionArns[0]')
    
    if [ "${?}" -ne 0 ]; then
        echo "[+] Failed to get task definition"
        exit 1
    fi
}

create_spec_file(){
    cat << EOF > ${SPEC_FILE}
version: v1.0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: ${TASK_DEFINITION}
        LoadBalancerInfo:
          ContainerName: ${containerName}
          ContainerPort: ${containerPort}
EOF
}

move_spec_file_to_s3(){
    aws s3 mv ${SPEC_FILE} s3://${bucketName}

    if [ "${?}" -ne 0 ]; then
        echo "[+] Failed to move ${SPEC_FILE} to bucket ${bucketName}"
        exit 1
    fi
}

create_deployment_file(){
cat << EOF > ${DEPLOYMENT_FILE}
{
    "applicationName": "${applicationName}",
    "deploymentGroupName": "${deploymentGroupName}",
    "revision": {
        "revisionType": "S3",
        "s3Location": {
            "bucket": "${bucketName}",
            "key": "${SPEC_FILE}",
            "bundleType": "YAML"
        }
    }
}
EOF
}

main(){
    aws deploy create-deployment \
        --cli-input-json file://${DEPLOYMENT_FILE} \
        --region ${region}

    if [ "${?}" -ne 0 ]; then
        echo "[+] Failed to create deployment"
        exit 1
    fi
}

validate_inputs
get_latest_task_definition
create_spec_file
move_spec_file_to_s3
create_deployment_file
main
