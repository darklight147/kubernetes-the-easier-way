![image](https://github.com/darklight147/kubernetes-the-easier-way/assets/39389636/b413e9bf-37cd-4af5-bb7b-9388dc5606a7)




# Kubernetes Cluster with Terraform and Ansible on AWS with Kubeadm

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=darklight147_kubernetes-the-easy-way&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=darklight147_kubernetes-the-easy-way)

### Skaffold a full Kubernetes Cluster with nothing but Terraform and ansible, and deploy a sample application on it.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (tested with 1.3.9)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (tested core with 2.14.4)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with your credentials (tested with 2.10.1)

Refer to the [AWS IAM User Configuration](./IAM.md) for more information on how to configure your AWS credentials.

## Clone the repository

```bash
$ git clone https://github.com/darklight147/kubernetes-the-easier-way.git
$ cd kubernetes-the-easier-way
```

## Infrastructure preparation

### Create a new S3 bucket

```bash
$ aws s3api create-bucket --bucket YOUR_BUCKET_NAME --region us-east-1
```

### Create a new DynamoDB table

```bash
$ aws dynamodb create-table --table-name YOUR_DYNAMODB_TABLE_NAME --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```

### Create a new Terraform backend configuration file

```bash
$ cat > backend.tfvars <<EOF
bucket = "YOUR_BUCKET_NAME"
dynamodb_table = "YOUR_DYNAMODB_TABLE_NAME"
region = "YOUR_AWS_REGION"
key = "terraform.tfstate"
EOF
```

## Structure

Finally, here is the structure of the project you just ended up with:

```bash
.
├── IAM.md
├── README.md
├── ansible
│   └── k8s.yml
├── backend.tfvars
├── main.tf
├── outputs.tf
├── providers.tf
└── variables.tf

2 directories, 11 files
```

## Usage

2. Initialize Terraform

```bash
$ terraform init -backend-config=backend.tfvars
```

3. Create the infrastructure

```bash
$ terraform apply
```

4. Say yes to the prompt and wait for the infrastructure to be created.

5. Done! You now have a fully functional Kubernetes cluster with 1 master and 1 worker.

<!-- ## Taking Control of the Cluster -->
