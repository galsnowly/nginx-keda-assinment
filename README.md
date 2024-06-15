# Deploying EKS Cluster with Keda and Nginx Auto-Scaling

This project demonstrates how to deploy an EKS cluster with Keda and configure auto-scaling of an Nginx deployment based on SQS queue length using Terraform and Terragrunt.

## Prerequisites

- Terraform
- Terragrunt
- AWS CLI
- kubectl
- helm

## Setup

1. **Clone the Repository:**

    ```sh
    git clone <repository-url>
    cd <repository-directory>
    ```

2. **Set AWS Credentials:**

    ```sh
    export AWS_PROFILE=my-profile
    export AWS_ACCESS_KEY_ID=<YOUR_AWS_ACCESS_KEY_ID>
    export AWS_SECRET_ACCESS_KEY=<YOUR_AWS_SECRET_ACCESS_KEY>
    ```

3. **Initialize and Apply Terragrunt:**

    Navigate to the root directory where `terragrunt.hcl` is defined for your environment:

    ```sh
    cd terraform-live/prod
    terragrunt apply-all
    ```

## Components

### VPC and EKS

- Creates a VPC with 3 availability zones.
- Deploys an EKS cluster with a node pool of 2 EC2 instances in private subnets.

### Keda

- Deploys Keda using the Helm provider in Terraform.

### SQS Queue

- Creates an SQS queue using Terraform.

### Nginx Deployment and Scaling

- Creates a Kubernetes Secret with AWS credentials.
- Deploys an Nginx deployment using Kubernetes resources defined in Terraform.
- Configures a `ScaledObject` with Keda to scale based on the SQS queue length.

## Testing the Setup

1. **Send Messages to the SQS Queue:**

    ```sh

    cd terraform-live/prod/keda

    queue_url=$(terraform output -raw queue_url)

    for x in {0..100}
    do
      aws sqs send-message --queue-url $queue_url --message-body "Test message $x"
    done
    ```

2. **Monitor Nginx Deployment:**

    ```sh
    kubectl get deployment nginx-deployment -n keda -w
    ```

## Clean Up

To clean up the resources created, run the following command from the root directory:

```sh
cd terraform-live/prod/
terragrunt destroy-all
```