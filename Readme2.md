#### Authenticate Docker with ECR
```$(aws ecr get-login --no-include-email --region us-east-1)```

#### Build the docker image 
```docker build -t my-python-api-server -f DockerFile .```

#### Tag the docker image 
```docker tag my-python-api-server:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/my-python-api-server:latest```

#### Push the docker image to ECR repo 
```docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/my-python-api-server:latest```

#### Deploy IaC infra into AWS
```terraform apply --auto-approve```

#### Generate base64-encoded docker configuration data which is needed in the secret.yaml file
```
kubectl create secret docker-registry my-ecr-secret \
 --docker-server=<account-id>.dkr.ecr.us-east-1.amazonaws.com \`
  --docker-username=AWS \`
  --docker-password=$(aws ecr get-login-password --region us-east-1) -o json | jq -r '.data.".dockerconfigjson"' | base64 --decode > ecr-secret.json
  ```
  
This file can now be used to create the secret in Helm Chart

#### To export the Kubernetes config 
aws eks --region us-east-1 update-kubeconfig --name dev

#### Test to verify the connection
kubectl get svc