
````markdown
# DevOps Kubernetes Training Lab

This repository documents my hands-on DevOps training lab using Docker Desktop, Minikube, Kubernetes, Helm, Terraform, GitHub Actions, and Jenkins.

The purpose of this project is to practice real-world DevOps responsibilities, including:

- Kubernetes application deployment
- Helm-based release management
- Infrastructure as Code with Terraform
- CI/CD automation with GitHub Actions and Jenkins
- Local Kubernetes operations and troubleshooting
- Multi-environment deployment using dev/stage/prod patterns

---

## 1. Training Environment

### Local Environment

I used my local Mac as the main DevOps training environment.

Main tools used:

| Tool | Purpose |
|---|---|
| Docker Desktop | Container runtime and local container image support |
| Minikube | Local Kubernetes cluster |
| kubectl | Kubernetes command-line operations |
| Helm | Kubernetes package manager and release management |
| Terraform | Infrastructure as Code |
| Git | Version control |
| GitHub | Remote repository and GitHub Actions CI/CD |
| GitHub Actions | CI/CD automation |
| Jenkins | CI/CD automation server |
| Homebrew | macOS package installation |

Project root:

```bash
~/devops-k8s-training
````

Main project structure:

```text
devops-k8s-training/
├── app/
├── k8s/
├── helm/
├── terraform/
├── migration/
├── ci/
├── .github/
│   └── workflows/
├── notes/
└── README.md
```

---

## 2. Docker and Minikube Setup

### What I practiced

I used Docker Desktop as the container runtime and Minikube as the local Kubernetes cluster.

Key commands practiced:

```bash
docker version
docker ps
docker images
docker volume ls
docker network ls
```

Minikube commands:

```bash
minikube start --driver=docker
minikube status
minikube stop
minikube delete
minikube image build -t demo-app:v1 ./app
minikube image ls
minikube service <service-name> -n <namespace>
```

Kubernetes cluster verification:

```bash
kubectl get nodes
kubectl cluster-info
kubectl get pods -A
```

### What I learned

* Docker Desktop provides the local container runtime.
* Minikube creates a local Kubernetes cluster for hands-on learning.
* Local images need to be built inside Minikube when using `imagePullPolicy: Never`.
* `kubectl` communicates with the current Kubernetes context, which should be `minikube`.

---

## 3. Simple Application Creation

### What I built

I created a simple Nginx-based demo app.

Project files:

```text
app/
├── Dockerfile
└── index.html
```

Example `Dockerfile`:

```dockerfile
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
```

Example `index.html`:

```html
<h1>Hello from Minikube DevOps Training</h1>
<p>Version: v1</p>
```

Build image inside Minikube:

```bash
minikube image build -t demo-app:v1 ./app
```

Verify image:

```bash
minikube image ls | grep demo-app
```

### What I learned

* A Dockerfile defines how to package an application into a container image.
* Minikube must have access to the image before Kubernetes can run it.
* Image tags are used to identify application versions.

---

## 4. Kubernetes Raw YAML Deployment

### What I practiced

I deployed the demo app using raw Kubernetes YAML with `kubectl`.

Main Kubernetes resources created:

| Resource                 | Purpose                                     |
| ------------------------ | ------------------------------------------- |
| Namespace                | Environment isolation                       |
| ConfigMap                | Non-sensitive configuration                 |
| Deployment               | Runs and manages application Pods           |
| Service                  | Exposes the application                     |
| Readiness Probe          | Checks whether the app is ready for traffic |
| Liveness Probe           | Checks whether the app should be restarted  |
| Resource Requests/Limits | Controls CPU and memory usage               |

Example commands:

```bash
kubectl apply -f k8s/namespace-dev.yaml
kubectl apply -f k8s/configmap.yaml -n dev
kubectl apply -f k8s/deployment.yaml -n dev
kubectl apply -f k8s/service.yaml -n dev
```

Verification:

```bash
kubectl get all -n dev
kubectl get pods -n dev -o wide
kubectl describe deployment demo-app -n dev
kubectl describe service demo-app -n dev
minikube service demo-app -n dev
```

### Rollout and rollback practice

Update image:

```bash
kubectl set image deployment/demo-app demo-app=demo-app:v2 -n dev
kubectl rollout status deployment/demo-app -n dev
```

Check rollout history:

```bash
kubectl rollout history deployment/demo-app -n dev
```

Rollback:

```bash
kubectl rollout undo deployment/demo-app -n dev
kubectl rollout status deployment/demo-app -n dev
```

### What I learned

* Raw Kubernetes YAML helps understand how Kubernetes resources work.
* Deployments manage desired state and self-healing.
* Services route traffic to Pods using label selectors.
* Rollout and rollback are core Kubernetes operations.
* `kubectl describe`, `kubectl logs`, and `kubectl get events` are essential troubleshooting commands.

---

## 5. Helm Training

### What I practiced

After learning raw Kubernetes YAML, I converted the app deployment into a Helm chart.

Helm chart structure:

```text
helm/
└── demo-app/
    ├── Chart.yaml
    ├── values.yaml
    ├── values/
    │   ├── values-dev.yaml
    │   ├── values-stage.yaml
    │   └── values-prod.yaml
    └── templates/
        ├── _helpers.tpl
        ├── configmap.yaml
        ├── deployment.yaml
        └── service.yaml
```

### Helm commands practiced

Install Helm chart:

```bash
helm install demo-app helm/demo-app -n dev
```

Upgrade Helm release:

```bash
helm upgrade demo-app helm/demo-app -n dev --set image.tag=v2
```

Rollback Helm release:

```bash
helm rollback demo-app 1 -n dev
```

Uninstall Helm release:

```bash
helm uninstall demo-app -n dev
```

Check Helm release:

```bash
helm list -n dev
helm status demo-app -n dev
helm history demo-app -n dev
```

Render chart without installing:

```bash
helm template demo-app helm/demo-app
```

Validate chart:

```bash
helm lint helm/demo-app
```

### Multi-environment Helm values

I created separate values files for:

```text
dev
stage
prod
```

Example deployment commands:

```bash
helm install demo-app-dev helm/demo-app \
  -n dev \
  -f helm/demo-app/values/values-dev.yaml
```

```bash
helm install demo-app-stage helm/demo-app \
  -n stage \
  -f helm/demo-app/values/values-stage.yaml
```

```bash
helm install demo-app-prod helm/demo-app \
  -n prod \
  -f helm/demo-app/values/values-prod.yaml
```

### What I learned

* Helm turns Kubernetes YAML into reusable templates.
* `values.yaml` allows different settings for different environments.
* `helm upgrade --install` is commonly used in CI/CD.
* Helm tracks release history.
* Helm rollback should be used when the app was deployed by Helm.
* `helm lint` and `helm template` are useful for validation before deployment.

---

## 6. Docker Desktop Service Migration Practice

### What I practiced

I reviewed how existing Docker Desktop services can be migrated into Minikube.

Docker-to-Kubernetes mapping:

| Docker / Compose      | Kubernetes               |
| --------------------- | ------------------------ |
| Container             | Pod                      |
| Service               | Deployment               |
| Port mapping          | Service                  |
| Environment variables | ConfigMap / Secret       |
| Volume                | PersistentVolumeClaim    |
| Compose network       | Kubernetes DNS / Service |
| Restart policy        | Deployment self-healing  |

Inventory commands practiced:

```bash
docker ps
docker inspect <container-name>
docker logs <container-name>
docker compose ls
docker volume ls
```

### What I learned

* Docker containers are not directly “moved” into Kubernetes.
* Services are converted into Kubernetes resources.
* Stateless services are easier to migrate.
* Stateful services need PVCs and careful backup planning.
* Kubernetes Services provide DNS-based service discovery.

---

## 7. Terraform Deep DevOps Training

### What I practiced

I used Terraform to manage Kubernetes resources and Helm releases.

Terraform folder structure:

```text
terraform/
├── envs/
│   ├── dev/
│   ├── stage/
│   ├── prod/
│   └── helm-dev/
└── modules/
    ├── k8s-app/
    └── helm-app/
```

### Terraform concepts learned

| Concept         | Meaning                                                                |
| --------------- | ---------------------------------------------------------------------- |
| Provider        | Plugin that lets Terraform manage a platform                           |
| Resource        | Infrastructure object managed by Terraform                             |
| Variable        | Input value used to make code reusable                                 |
| tfvars          | File containing environment-specific variable values                   |
| Output          | Terraform return value after apply                                     |
| State           | Terraform’s record of managed infrastructure                           |
| Drift           | Difference between real infrastructure and Terraform desired state     |
| Drift Detection | Using `terraform plan` to detect differences                           |
| Module          | Reusable Terraform code                                                |
| Import          | Bring existing resources under Terraform management                    |
| Workspace       | Separate state instances for same configuration                        |
| Backend         | Where Terraform state is stored                                        |
| State Locking   | Prevents multiple Terraform runs from modifying state at the same time |

### Terraform commands practiced

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
terraform output
terraform state list
terraform state show <resource>
terraform import <resource> <id>
terraform workspace list
terraform workspace new dev
terraform workspace select dev
```

### Kubernetes resources managed by Terraform

I practiced managing:

```text
Namespace
ConfigMap
Secret
Deployment
Service
PersistentVolumeClaim
```

### Example Terraform workflow

```bash
cd ~/devops-k8s-training/terraform/envs/dev

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

### Drift detection practice

I manually changed the Kubernetes Deployment outside Terraform:

```bash
kubectl scale deployment demo-app --replicas=5 -n dev
```

Then detected drift:

```bash
terraform plan
```

Then reconciled it:

```bash
terraform apply
```

### What I learned

* Terraform manages desired infrastructure state.
* Manual changes can cause drift.
* `terraform plan` is the review step before applying changes.
* `terraform apply` reconciles real infrastructure with Terraform code.
* Terraform state is critical and should not be committed to Git.
* Variables and `terraform.tfvars` support environment-specific configuration.
* Outputs are useful for exposing created resource names and values.
* Modules prevent copy-pasting Terraform code.
* Terraform can also manage Helm releases using `helm_release`.

---

## 8. GitHub Actions CI/CD Training

### What I practiced

I created GitHub Actions workflows for CI/CD automation.

GitHub Actions workflow folder:

```text
.github/
└── workflows/
```

### Git and GitHub commands practiced

```bash
git status
git add .
git commit -m "message"
git push
git branch -M main
git remote add origin git@github.com:<username>/devops-k8s-training.git
git push -u origin main
```

### Workflows created

| Workflow                           | Purpose                                    |
| ---------------------------------- | ------------------------------------------ |
| Basic CI                           | Verify GitHub Actions can run automation   |
| Docker Build                       | Build Docker image in CI                   |
| Helm Validate                      | Run `helm lint` and `helm template`        |
| Terraform Validate                 | Run Terraform format and validation checks |
| Self-hosted Runner Check           | Verify GitHub Actions can run on my Mac    |
| Deploy to Local Minikube with Helm | Deploy app to Minikube using Helm          |

### GitHub Actions concepts learned

| Concept              | Meaning                                    |
| -------------------- | ------------------------------------------ |
| Workflow             | Automation file under `.github/workflows/` |
| Trigger              | Event that starts a workflow               |
| Job                  | Group of steps                             |
| Step                 | Individual command or action               |
| Runner               | Machine that executes workflow             |
| GitHub-hosted runner | Cloud VM provided by GitHub                |
| Self-hosted runner   | My own Mac used as a runner                |
| `workflow_dispatch`  | Manual workflow trigger                    |
| `actions/checkout`   | Downloads repository code into runner      |

### Docker build workflow

I practiced:

```bash
docker build -t demo-app:${{ github.sha }} ./app
docker images | grep demo-app
```

### Helm validation workflow

I practiced:

```bash
helm lint helm/demo-app
helm template demo-app-dev helm/demo-app -f helm/demo-app/values/values-dev.yaml
helm template demo-app-stage helm/demo-app -f helm/demo-app/values/values-stage.yaml
helm template demo-app-prod helm/demo-app -f helm/demo-app/values/values-prod.yaml
```

### Terraform validation workflow

I practiced:

```bash
terraform fmt -check
terraform init
terraform validate
```

### Self-hosted runner

I learned that GitHub-hosted runners cannot access my local Minikube cluster because Minikube runs on my Mac.

So I used a self-hosted runner:

```text
GitHub Actions workflow
        ↓
Self-hosted runner on my Mac
        ↓
Local Docker / Minikube / kubectl / Helm
        ↓
Deploy to local Minikube
```

### GitHub Actions Helm deployment

I completed a workflow that performs:

```text
Manual workflow trigger
Check local tools
Build image inside Minikube
Validate Helm chart
Deploy with Helm
Show Helm release
Show Kubernetes resources
Verify rollout
```

Important commands used:

```bash
minikube image build -t demo-app:<tag> ./app

helm lint helm/demo-app

helm template demo-app-dev helm/demo-app \
  -f helm/demo-app/values/values-dev.yaml \
  --set image.tag=<tag>

helm upgrade --install demo-app-dev helm/demo-app \
  -n dev \
  --create-namespace \
  -f helm/demo-app/values/values-dev.yaml \
  --set image.tag=<tag>

helm list -n dev
helm status demo-app-dev -n dev
helm history demo-app-dev -n dev

kubectl get all -n dev
kubectl get pods -n dev -o wide
kubectl rollout status deployment/<deployment-name> -n dev
```

### What I learned

* GitHub Actions can automate CI/CD from GitHub.
* Workflows are stored as YAML.
* Docker, Helm, and Terraform validation can run automatically.
* Local Minikube deployment requires a self-hosted runner.
* `helm upgrade --install` is useful for deployment pipelines.
* CI/CD should validate before deployment.
* Deployment verification should include Helm status and Kubernetes rollout checks.

---

## 9. Jenkins CI/CD Training

### What I practiced

I completed Jenkins-based CI/CD training using my local Jenkins instance:

```text
http://localhost:8080
```

### Jenkins concepts learned

| Jenkins Concept    | Meaning                              |
| ------------------ | ------------------------------------ |
| Jenkins controller | Main Jenkins server and UI           |
| Job / Project      | A task Jenkins can run               |
| Build              | One execution of a job               |
| Pipeline           | CI/CD workflow                       |
| Jenkinsfile        | Pipeline definition stored as code   |
| Stage              | Major section of pipeline            |
| Step               | Individual command inside a stage    |
| Agent              | Machine/executor where pipeline runs |
| Workspace          | Directory where Jenkins runs the job |
| Console Output     | Jenkins build logs                   |
| Parameters         | User inputs before build             |
| Credentials        | Secure secrets stored in Jenkins     |

### Jenkins setup verification

I verified Jenkins and local tools:

```bash
brew services list | grep jenkins
brew services start jenkins-lts
```

Tool checks:

```bash
git --version
docker version
minikube status
kubectl get nodes
helm version
terraform version
```

### Basic Jenkins Pipeline

I created a simple Jenkins pipeline to confirm Jenkins can run jobs.

Example structure:

```groovy
pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello from Jenkins Pipeline'
            }
        }

        stage('Show Info') {
            steps {
                sh '''
                whoami
                pwd
                hostname
                '''
            }
        }
    }
}
```

### Jenkins tool check pipeline

I practiced verifying that Jenkins can run:

```bash
git --version
docker version
minikube status
kubectl config current-context
kubectl get nodes
helm version
terraform version
```

### Jenkinsfile as pipeline code

I created:

```text
ci/Jenkinsfile
```

I learned that storing pipeline configuration in Git allows:

```text
version control
review
repeatability
team collaboration
```

### Jenkins Pipeline from SCM

I practiced or prepared Jenkins to load the pipeline from:

```text
Git repository
Script Path: ci/Jenkinsfile
```

This matches a real CI/CD pattern:

```text
Jenkins job
        ↓
Pull code from GitHub
        ↓
Read Jenkinsfile
        ↓
Run pipeline stages
```

### Jenkins CI stages practiced

I practiced Jenkins stages for:

```text
Show workspace
Check local tools
Build Docker image
Build image inside Minikube
Helm lint
Helm template
Helm deployment
Helm release verification
Kubernetes resource verification
Rollout verification
```

### Jenkins Helm deployment pipeline

I created a Jenkins pipeline that supports parameters:

```text
IMAGE_TAG
ENVIRONMENT
```

Example:

```groovy
parameters {
    string(name: 'IMAGE_TAG', defaultValue: 'jenkins-v1', description: 'Image tag to deploy')
    choice(name: 'ENVIRONMENT', choices: ['dev', 'stage', 'prod'], description: 'Target environment')
}
```

### Jenkins deployment flow

The Jenkins deployment pipeline performs:

```text
Build with Parameters
        ↓
Check local tools
        ↓
Build image inside Minikube
        ↓
Validate Helm chart
        ↓
Render Helm template
        ↓
Deploy with Helm
        ↓
Check Helm release
        ↓
Check Kubernetes resources
        ↓
Verify rollout
```

Important commands practiced:

```bash
minikube image build -t demo-app:jenkins-v1 ./app

helm lint helm/demo-app

helm template demo-app-dev helm/demo-app \
  -f helm/demo-app/values/values-dev.yaml \
  --set image.tag=jenkins-v1

helm upgrade --install demo-app-dev helm/demo-app \
  -n dev \
  --create-namespace \
  -f helm/demo-app/values/values-dev.yaml \
  --set image.tag=jenkins-v1

helm list -n dev
helm status demo-app-dev -n dev
helm history demo-app-dev -n dev

kubectl get all -n dev
kubectl get pods -n dev -o wide
kubectl get svc -n dev
kubectl rollout status deployment/<deployment-name> -n dev
```

### Jenkins manual approval

I studied Jenkins manual approval using:

```groovy
input message: "Deploy to PROD?", ok: "Deploy"
```

Purpose:

```text
Pause production deployment until a human approves.
```

### Jenkins Terraform validation

I practiced or prepared Terraform validation inside Jenkins:

```groovy
stage('Terraform Validate Dev') {
    steps {
        dir('terraform/envs/dev') {
            sh '''
            terraform init
            terraform fmt -check
            terraform validate
            '''
        }
    }
}
```

### Jenkins troubleshooting practiced

I learned how to troubleshoot:

```text
Jenkinsfile syntax errors
wrong Jenkinsfile path
Git checkout issues
missing command in PATH
Jenkins cannot find helm/kubectl/minikube
Jenkins cannot access Minikube
Helm deployment failures
Kubernetes rollout failures
```

Helpful commands:

```groovy
sh 'echo $PATH'
sh 'which helm || true'
sh 'which kubectl || true'
sh 'which minikube || true'
sh 'whoami'
sh 'echo $HOME'
sh 'ls -la ~/.kube || true'
```

### What I learned

* Jenkins can be used as a CI/CD automation server.
* Jenkins Pipeline can be written as code using a Jenkinsfile.
* Jenkins can run shell commands on my Mac.
* Jenkins can build images inside Minikube.
* Jenkins can deploy Helm releases to Minikube.
* Parameters allow the same pipeline to deploy different image tags and environments.
* Console Output is the main troubleshooting place.
* Jenkins CI/CD is similar in purpose to GitHub Actions, but uses Jenkins jobs and Jenkinsfiles.

---

## 10. Kubernetes Troubleshooting Skills Practiced

Throughout the training, I practiced Kubernetes troubleshooting commands:

```bash
kubectl get pods -A
kubectl get pods -n dev -o wide
kubectl describe pod <pod-name> -n dev
kubectl logs <pod-name> -n dev
kubectl logs <pod-name> -n dev --previous
kubectl get events -n dev --sort-by=.metadata.creationTimestamp
kubectl get svc -n dev
kubectl describe svc <service-name> -n dev
kubectl get endpoints -n dev
kubectl get pods -n dev --show-labels
```

Common issues studied:

| Issue                    | Meaning                                       |
| ------------------------ | --------------------------------------------- |
| ImagePullBackOff         | Kubernetes cannot pull or find the image      |
| CrashLoopBackOff         | Container starts and repeatedly crashes       |
| Pending Pod              | Pod cannot be scheduled                       |
| Service has no endpoints | Service selector does not match Pod labels    |
| Rollout failure          | New Deployment version did not become healthy |

---

## 11. Overall Skills Completed

### Kubernetes

* Created namespaces
* Deployed app using raw YAML
* Used Deployment, Service, ConfigMap
* Used probes and resource limits
* Performed rollout and rollback
* Used `kubectl` for troubleshooting

### Helm

* Created Helm chart
* Used templates
* Used `values.yaml`
* Created dev/stage/prod values
* Installed, upgraded, rolled back, and uninstalled releases
* Validated charts with `helm lint` and `helm template`

### Terraform

* Used providers
* Created Kubernetes resources
* Used variables and tfvars
* Used outputs
* Inspected state
* Practiced drift detection
* Used modules
* Managed Helm release with Terraform
* Practiced Terraform validation

### GitHub Actions

* Created CI workflows
* Built Docker image in CI
* Validated Helm chart
* Validated Terraform
* Used self-hosted runner
* Deployed to local Minikube with Helm

### Jenkins

* Created Jenkins Pipeline jobs
* Used Jenkinsfile
* Checked tools from Jenkins
* Built images
* Validated Helm
* Deployed to Minikube with Helm
* Used parameters
* Studied manual approval
* Practiced troubleshooting

---

## 12. Current Training Status

| Area                              | Status                                        |
| --------------------------------- | --------------------------------------------- |
| Docker Desktop                    | Completed                                     |
| Minikube                          | Completed                                     |
| Kubernetes raw YAML               | Completed                                     |
| Helm                              | Completed                                     |
| Terraform                         | Completed                                     |
| GitHub Actions CI/CD              | Completed through Helm deployment to Minikube |
| Jenkins CI/CD                     | Completed                                     |
| GitLab CI                         | Planned                                       |
| Monitoring                        | Planned                                       |
| Incident response and post-mortem | Planned                                       |
| Argo CD + GitOps                  | Planned                                       |
| AWS/EKS extension                 | Planned                                       |

---

## 13. Next Planned Training Items

Future training items:

```text
1. GitLab CI/CD
2. Monitoring with metrics-server, Prometheus, and Grafana
3. Incident response and post-mortem practice
4. Argo CD + Helm GitOps
5. AWS EKS deployment
6. Terraform AWS provider for VPC, IAM, EKS, S3
7. CI/CD deployment to AWS/EKS
```

---

## 14. Resume-Ready Project Summary

Built a local DevOps Kubernetes training platform using Docker Desktop, Minikube, Kubernetes, Helm, Terraform, GitHub Actions, and Jenkins. Practiced application deployment with raw Kubernetes YAML, converted manifests into Helm charts with dev/stage/prod values, managed Kubernetes resources and Helm releases with Terraform, and implemented CI/CD workflows using GitHub Actions and Jenkins to build, validate, and deploy applications to Minikube.

### Resume bullet

```text
Designed and implemented a local DevOps CI/CD training lab using Docker Desktop, Minikube, Kubernetes, Helm, Terraform, GitHub Actions, and Jenkins. Deployed applications using Kubernetes YAML and Helm, managed infrastructure with Terraform, automated validation and deployment pipelines, and practiced Kubernetes rollout, rollback, and troubleshooting workflows.
```

### Stronger resume bullet

```text
Built an end-to-end local Kubernetes DevOps platform using Minikube, Helm, Terraform, GitHub Actions, and Jenkins. Automated Docker image builds, Helm chart validation, Terraform validation, and Helm-based deployments to dev/stage/prod namespaces. Practiced Infrastructure as Code, CI/CD pipeline design, Kubernetes troubleshooting, rollout verification, and release rollback workflows.
```

```
```
````markdown
# AWS DevOps Hands-on Training Summary

## Overview

This training project was created to strengthen practical AWS infrastructure, DevOps, Kubernetes, Terraform, CI/CD, monitoring, automation, cost control, and incident response skills.

The hands-on labs focused on:

- Building and supporting AWS-based infrastructure
- Operating and troubleshooting Kubernetes clusters
- Managing infrastructure using Terraform / Infrastructure as Code
- Supporting CI/CD pipelines
- Monitoring system health and performance
- Improving cost visibility and cleanup practices
- Writing Bash and Python automation scripts
- Practicing incident response and post-mortem documentation
- Understanding high availability with load balancing and auto scaling

---

## 1. AWS Account, IAM, SSO, and CLI Setup

### What I practiced

- Secured AWS account root user with MFA
- Used IAM Identity Center / SSO for daily admin login
- Configured AWS CLI profile `devops-admin`
- Verified AWS identity and active region
- Troubleshot region mismatch between CLI and actual AWS resources

### Commands practiced

```bash
aws configure list --profile devops-admin

aws sts get-caller-identity --profile devops-admin

aws configure set region us-east-2 --profile devops-admin

aws ec2 describe-instances \
  --region us-east-2 \
  --profile devops-admin
````

### What I learned

* Root user should not be used for daily operations
* SSO / IAM Identity Center provides safer temporary credentials
* AWS CLI commands are region-scoped for regional services like EC2
* If AWS CLI cannot find a resource, region mismatch is one of the first things to check

---

## 2. EC2 Basic Operations and Troubleshooting

### What I practiced

* Launched EC2 instances
* Connected to EC2 using SSH key pair
* Installed and started Nginx on Amazon Linux 2023
* Verified service locally using `curl localhost`
* Troubleshot public access issues from my laptop
* Checked EC2 public IP, private IP, subnet, VPC, and security group
* Fixed HTTP access by updating Security Group inbound rules

### Commands practiced

```bash
ssh -i ~/.ssh/devops-practice-key.pem ec2-user@<public-ip>

sudo dnf update -y
sudo dnf install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx

curl localhost

aws ec2 describe-instances \
  --filters "Name=ip-address,Values=<public-ip>" \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,PrivateIpAddress,SubnetId,VpcId,SecurityGroups[*].GroupId]" \
  --output table \
  --profile devops-admin

aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --profile devops-admin
```

### What I learned

* If `curl localhost` works inside EC2 but public access fails, the application is running but network access is blocked
* Common causes include Security Group, subnet route table, public IP, NACL, or OS firewall
* Security Group inbound rules control whether external users can access EC2 ports
* EC2 public IP can change after stop/start unless Elastic IP is used

---

## 3. S3 Basic Operations

### What I practiced

* Created S3 buckets
* Uploaded and downloaded objects
* Enabled versioning and encryption
* Blocked public access
* Deleted objects and buckets safely

### Commands practiced

```bash
aws s3 mb s3://<bucket-name> --region us-east-2 --profile devops-admin

aws s3 cp hello.txt s3://<bucket-name>/ --profile devops-admin

aws s3 ls s3://<bucket-name>/ --profile devops-admin

aws s3 cp s3://<bucket-name>/hello.txt downloaded.txt --profile devops-admin

aws s3 rm s3://<bucket-name>/hello.txt --profile devops-admin

aws s3 rb s3://<bucket-name> --profile devops-admin
```

### What I learned

* S3 is object storage, not a traditional file system
* Bucket names must be globally unique
* Versioning and encryption are important production best practices
* Public access should be blocked unless there is a clear business reason

---

## 4. Terraform Infrastructure as Code

### What I practiced

* Installed and used Terraform
* Created S3 bucket using Terraform
* Created EC2 instance using Terraform
* Created VPC, subnet, Internet Gateway, route table, security group, and EC2 using Terraform
* Used `provider.tf`, `main.tf`, `variables.tf`, `outputs.tf`, and `data.tf`
* Fixed Terraform EC2 creation failure caused by missing default subnet
* Practiced explicit VPC and subnet configuration instead of relying on default VPC

### Commands practiced

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform destroy
```

### What I learned

* Terraform code describes desired infrastructure
* Terraform state tracks real AWS resources managed by Terraform
* `terraform plan` previews infrastructure changes before applying
* `terraform apply` creates or updates infrastructure
* `terraform destroy` deletes resources managed by Terraform
* Production-style Terraform should explicitly define or reference VPC and subnet resources
* Relying on default VPC/default subnet can cause errors

---

## 5. Terraform Remote State

### What I practiced

* Created an S3 bucket for Terraform remote state
* Enabled versioning, encryption, and public access block on the state bucket
* Configured Terraform S3 backend
* Verified Terraform state was stored in S3 instead of local-only state

### Commands practiced

```bash
aws s3api create-bucket \
  --bucket <terraform-state-bucket> \
  --region us-east-2 \
  --create-bucket-configuration LocationConstraint=us-east-2 \
  --profile devops-admin

aws s3api put-bucket-versioning \
  --bucket <terraform-state-bucket> \
  --versioning-configuration Status=Enabled \
  --profile devops-admin

terraform init
terraform apply

aws s3 ls s3://<terraform-state-bucket>/practice/05-remote-state/ \
  --profile devops-admin
```

### What I learned

* Local Terraform state is okay for personal learning, but remote state is better for teams
* S3 remote state allows multiple engineers or CI/CD pipelines to work from shared infrastructure state
* Terraform state may contain sensitive infrastructure details, so it should not be committed to GitHub
* GitHub stores Terraform source code, while S3 stores Terraform state

---

## 6. Terraform Modules

### What I practiced

* Created reusable Terraform modules
* Built an S3 module with `main.tf`, `variables.tf`, and `outputs.tf`
* Called the module from a root Terraform configuration
* Reused the same module with different input values

### Example structure practiced

```text
06-modules/
  modules/
    s3-basic/
      main.tf
      variables.tf
      outputs.tf

  live/
    provider.tf
    main.tf
    outputs.tf
```

### Commands practiced

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

### What I learned

* Modules help avoid copy/paste Terraform code
* Modules should define reusable infrastructure logic
* Root environment folders should usually own provider and backend configuration
* Modules should not usually hardcode AWS region, profile, or backend settings

---

## 7. Terraform Multi-Environment Structure

### What I practiced

* Created separate Terraform environment folders for `dev` and `stage`
* Used the same module for multiple environments
* Used different bucket names and environment values for each environment
* Practiced the idea of separate state per environment

### Example structure practiced

```text
07-multi-env/
  modules/
    s3-basic/

  environments/
    dev/
      provider.tf
      main.tf
      outputs.tf

    stage/
      provider.tf
      main.tf
      outputs.tf
```

### Commands practiced

```bash
cd environments/dev
terraform init
terraform plan
terraform apply

cd ../stage
terraform init
terraform plan
terraform apply

terraform destroy
```

### What I learned

* Real teams usually separate dev, stage, and prod environments
* The same module can be reused with different environment values
* Each environment should have its own Terraform state
* Environment separation reduces risk of accidentally changing production resources

---

## 8. CloudWatch Monitoring and SNS Alerts

### What I practiced

* Created SNS topic for alert notification
* Subscribed email to SNS topic
* Created CloudWatch CPU alarm for EC2
* Generated CPU load to test alarm behavior
* Verified alarm state and email notification

### Commands practiced

```bash
aws sns create-topic \
  --name devops-practice-alerts \
  --profile devops-admin

aws sns subscribe \
  --topic-arn <topic-arn> \
  --protocol email \
  --notification-endpoint <email> \
  --profile devops-admin

aws cloudwatch put-metric-alarm \
  --alarm-name devops-practice-high-cpu \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value=<instance-id> \
  --evaluation-periods 1 \
  --alarm-actions <topic-arn> \
  --unit Percent \
  --profile devops-admin

aws cloudwatch describe-alarms \
  --alarm-names devops-practice-high-cpu \
  --profile devops-admin
```

### What I learned

* CloudWatch metrics help monitor infrastructure health
* CloudWatch alarms detect abnormal conditions
* SNS can send alarm notifications by email
* Monitoring is critical for production operations and incident response

---

## 9. ECR Docker Image Registry

### What I practiced

* Created Amazon ECR repository
* Built a local Docker image
* Logged Docker into ECR
* Tagged image with ECR repository URI
* Pushed image to ECR
* Verified image existed in ECR

### Commands practiced

```bash
aws ecr create-repository \
  --repository-name devops-demo-app \
  --image-scanning-configuration scanOnPush=true \
  --region us-east-2 \
  --profile devops-admin

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --profile devops-admin)
REGION=us-east-2
REPO_URI=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/devops-demo-app

aws ecr get-login-password \
  --region us-east-2 \
  --profile devops-admin | \
docker login \
  --username AWS \
  --password-stdin ${ACCOUNT_ID}.dkr.ecr.us-east-2.amazonaws.com

docker build -t devops-demo-app:latest .
docker tag devops-demo-app:latest ${REPO_URI}:latest
docker push ${REPO_URI}:latest

aws ecr describe-images \
  --repository-name devops-demo-app \
  --region us-east-2 \
  --profile devops-admin
```

### What I learned

* ECR stores Docker images
* GitHub stores source code, while ECR stores built container images
* Docker images must be tagged with the full ECR repository URI before pushing
* `${REPO_URI}:latest` is safer than `$REPO_URI:latest` in shell scripts

---

## 10. GitHub Actions to AWS ECR CI/CD

### What I practiced

* Created a standalone GitHub repo for `ecr-demo-app`
* Created GitHub Actions workflow
* Configured GitHub repository secrets
* Created IAM user for beginner CI/CD lab
* Attached ECR permissions to GitHub Actions IAM user
* Built Docker image automatically on push to `main`
* Logged in to ECR from GitHub Actions
* Pushed Docker image to ECR
* Verified image in ECR

### Workflow practiced

```text
GitHub push
→ GitHub Actions starts
→ Checkout source code
→ Configure AWS credentials
→ Confirm AWS identity
→ Login to Amazon ECR
→ Build Docker image
→ Tag Docker image
→ Push Docker image to ECR
→ Verify image in ECR
```

### Commands practiced

```bash
git init
git branch -M main
git remote add origin git@github.com:snowwin88/ecr-demo-app.git
git add .
git commit -m "Add ECR demo app with GitHub Actions workflow"
git push -u origin main

aws iam create-user \
  --user-name github-actions-ecr-user \
  --profile devops-admin

aws iam create-access-key \
  --user-name github-actions-ecr-user \
  --profile devops-admin

aws iam attach-user-policy \
  --user-name github-actions-ecr-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser \
  --profile devops-admin
```

### What I learned

* GitHub Actions can automate Docker build and push workflows
* GitHub repository secrets store sensitive CI/CD credentials
* IAM credentials authenticate the workflow, but IAM policies authorize what it can do
* Missing `ecr:GetAuthorizationToken` causes ECR login failure
* For production, GitHub OIDC is preferred over long-term IAM user access keys

---

## 11. EKS Basic Kubernetes Practice

### What I practiced

* Verified existing `kubectl` installation
* Installed/used `eksctl`
* Created an EKS cluster
* Verified Kubernetes nodes and system pods
* Deployed Nginx
* Exposed Nginx using Kubernetes `Service type=LoadBalancer`
* Checked pods, services, events, logs, and nodes
* Scaled deployment replicas
* Deleted a pod and observed Kubernetes self-healing
* Cleaned up EKS cluster to avoid cost

### Commands practiced

```bash
kubectl version --client
kubectl config current-context
kubectl config get-contexts

eksctl create cluster \
  --name devops-practice-eks \
  --region us-east-2 \
  --nodes 2 \
  --node-type t3.small \
  --profile devops-admin

kubectl get nodes
kubectl get pods -A

kubectl create deployment nginx --image=nginx
kubectl get deployment
kubectl get pods -o wide

kubectl expose deployment nginx \
  --type=LoadBalancer \
  --port=80

kubectl get svc

kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events --sort-by=.lastTimestamp

kubectl scale deployment nginx --replicas=3

kubectl delete pod <pod-name>

kubectl delete service nginx
kubectl delete deployment nginx

eksctl delete cluster \
  --name devops-practice-eks \
  --region us-east-2 \
  --profile devops-admin
```

### What I learned

* Minikube and EKS use the same core Kubernetes commands
* `kubectl` uses kubeconfig context to decide whether it talks to Minikube or EKS
* EKS maps local Kubernetes concepts to AWS-managed Kubernetes
* `Service type=LoadBalancer` can create an AWS load balancer
* Kubernetes Deployment maintains desired pod state
* EKS resources should be deleted quickly after labs to avoid cost

---

## 12. ALB and Auto Scaling Group

### What I practiced

* Created second public subnet for ALB
* Verified route table had `0.0.0.0/0 -> Internet Gateway`
* Enabled public IP auto-assignment on subnet
* Created ALB Security Group
* Created EC2 Security Group allowing HTTP from ALB SG
* Created Launch Template with Nginx user data
* Created Target Group and health check
* Created internet-facing Application Load Balancer
* Created HTTP listener on port 80
* Created Auto Scaling Group with desired capacity 2
* Verified target health
* Tested ALB DNS endpoint
* Terminated one instance and observed ASG replacement
* Troubleshot unhealthy target status

### Commands practiced

```bash
aws ec2 describe-subnets \
  --region us-east-2 \
  --filters "Name=vpc-id,Values=<vpc-id>" \
  --profile devops-admin

aws ec2 modify-subnet-attribute \
  --region us-east-2 \
  --subnet-id <subnet-id> \
  --map-public-ip-on-launch \
  --profile devops-admin

aws ec2 describe-route-tables \
  --region us-east-2 \
  --filters "Name=association.subnet-id,Values=<subnet-id>" \
  --output json \
  --profile devops-admin

aws ec2 associate-route-table \
  --region us-east-2 \
  --route-table-id <route-table-id> \
  --subnet-id <subnet-id> \
  --profile devops-admin

aws ec2 create-security-group \
  --group-name alb-public-http-sg \
  --description "Allow public HTTP to ALB" \
  --vpc-id <vpc-id> \
  --profile devops-admin

aws ec2 authorize-security-group-ingress \
  --group-id <alb-sg-id> \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --profile devops-admin

aws ec2 create-launch-template \
  --launch-template-name devops-nginx-template \
  --launch-template-data file://launch-template-data.json \
  --profile devops-admin

aws elbv2 create-target-group \
  --name devops-nginx-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id <vpc-id> \
  --target-type instance \
  --health-check-path / \
  --profile devops-admin

aws elbv2 create-load-balancer \
  --name devops-nginx-alb \
  --subnets <subnet-1> <subnet-2> \
  --security-groups <alb-sg-id> \
  --scheme internet-facing \
  --type application \
  --profile devops-admin

aws elbv2 create-listener \
  --load-balancer-arn <alb-arn> \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=<tg-arn> \
  --profile devops-admin

aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name devops-nginx-asg \
  --launch-template LaunchTemplateName=devops-nginx-template,Version='$Latest' \
  --min-size 1 \
  --max-size 3 \
  --desired-capacity 2 \
  --vpc-zone-identifier "<subnet-1>,<subnet-2>" \
  --target-group-arns <tg-arn> \
  --health-check-type ELB \
  --profile devops-admin

aws elbv2 describe-target-health \
  --target-group-arn <tg-arn> \
  --profile devops-admin
```

### What I learned

* ALB requires at least two subnets in different Availability Zones
* A public subnet needs a route to Internet Gateway
* ALB Security Group should allow public HTTP
* EC2 Security Group can allow HTTP only from ALB Security Group
* Target Group health checks determine whether ALB sends traffic to an instance
* Auto Scaling Group maintains desired capacity
* `healthy`, `unhealthy`, and `draining` target states are important for troubleshooting
* If one instance becomes unhealthy or terminated, ASG can launch a replacement

---

## 13. Bash and Python AWS Automation Scripts

### What I practiced

* Created Bash scripts for AWS inventory and cleanup checks
* Created Python `boto3` scripts for EC2 inventory and security checks
* Listed running EC2 instances
* Audited Security Groups allowing public SSH
* Found unattached EBS volumes
* Listed ECR images
* Checked cost-related resources such as EC2, EBS, ALB, and EKS

### Scripts created

```text
scripts/aws/
  ec2_inventory.sh
  find_public_ssh.sh
  find_unattached_volumes.sh
  ecr_images.sh
  aws_cleanup_check.sh
  ec2_inventory.py
  audit_public_ssh.py
  find_unattached_volumes.py
```

### Commands practiced

```bash
chmod +x ec2_inventory.sh
./ec2_inventory.sh

chmod +x find_public_ssh.sh
./find_public_ssh.sh

chmod +x find_unattached_volumes.sh
./find_unattached_volumes.sh

chmod +x aws_cleanup_check.sh
./aws_cleanup_check.sh

python3 ec2_inventory.py
python3 audit_public_ssh.py
python3 find_unattached_volumes.py
```

### What I learned

* Automation scripts reduce repetitive manual work
* AWS CLI scripts are useful for quick operational checks
* Python `boto3` scripts are useful for more flexible automation
* Public SSH exposure can be audited automatically
* Unattached EBS volumes can create unnecessary cost
* Cost cleanup scripts help avoid forgotten resources after training labs

---

## 14. Incident Response and Post-Mortem Documentation

### What I practiced

* Documented real troubleshooting scenarios
* Used incident response format with impact, detection, investigation, root cause, resolution, verification, and prevention
* Converted hands-on issues into reusable post-mortem examples

### Incidents documented

```text
incidents/
  incident-http-security-group.md
  incident-region-mismatch.md
  incident-terraform-default-subnet.md
  incident-github-actions-ecr-permission.md
```

### Incident scenarios practiced

1. EC2 HTTP service unreachable from internet
2. AWS CLI could not find EC2 due to region mismatch
3. Terraform failed to create EC2 due to missing default subnet
4. GitHub Actions failed to push to ECR due to missing IAM ECR permission
5. ALB Target Group unhealthy target due to failed health checks

### What I learned

* Incident response is not only about fixing the issue; it is also about documenting what happened
* Good post-mortems include impact, detection, timeline, root cause, resolution, verification, and prevention
* Many production issues are caused by configuration errors, not application code
* Troubleshooting should follow a structured flow: check symptoms, isolate layers, verify assumptions, fix, and document prevention actions

---

## 15. Cost Control and Cleanup

### What I practiced

* Deleted temporary EC2 instances
* Destroyed Terraform-managed resources
* Deleted EKS cluster after lab
* Deleted ALB, Target Group, Launch Template, ASG, and Security Groups after testing
* Checked for running EC2, unattached EBS volumes, Load Balancers, and EKS clusters
* Used cleanup scripts to reduce surprise cost risk

### Commands practiced

```bash
terraform destroy

eksctl delete cluster \
  --name devops-practice-eks \
  --region us-east-2 \
  --profile devops-admin

aws autoscaling delete-auto-scaling-group \
  --auto-scaling-group-name devops-nginx-asg \
  --force-delete \
  --profile devops-admin

aws elbv2 delete-load-balancer \
  --load-balancer-arn <alb-arn> \
  --profile devops-admin

aws elbv2 delete-target-group \
  --target-group-arn <tg-arn> \
  --profile devops-admin

aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --profile devops-admin

aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --profile devops-admin

aws eks list-clusters \
  --region us-east-2 \
  --profile devops-admin
```

### What I learned

* Cloud resources can continue charging after labs if not cleaned up
* EKS, ALB, NAT Gateway, EBS, and EC2 are important resources to check after practice
* Cleanup is part of responsible DevOps operations
* Cost awareness is part of production engineering

---

## 16. Final Skills Summary

Through this training project, I practiced:

* AWS IAM, SSO, and CLI usage
* EC2 provisioning and troubleshooting
* S3 bucket operations and security configuration
* VPC, subnet, route table, Internet Gateway, and Security Group concepts
* Terraform Infrastructure as Code
* Terraform remote state with S3 backend
* Terraform modules
* Terraform multi-environment structure
* CloudWatch alarms and SNS notifications
* Docker image build and Amazon ECR push
* GitHub Actions CI/CD pipeline to ECR
* Kubernetes operations with Minikube and EKS
* ALB, Target Group, Launch Template, and Auto Scaling Group
* Bash and Python automation for AWS operations
* Cost cleanup checks
* Incident response and post-mortem documentation

---

## 17. Project Summary

This project helped me build practical AWS and DevOps hands-on experience. I practiced provisioning and troubleshooting AWS infrastructure including EC2, S3, IAM, VPC, Security Groups, ALB, Auto Scaling, ECR, CloudWatch, and EKS. I also used Terraform to manage infrastructure as code, including remote state, modules, and multi-environment structure. For CI/CD, I built a GitHub Actions pipeline that builds a Docker image and pushes it to Amazon ECR. I also created Bash and Python automation scripts for inventory, security audit, and cost cleanup checks. Finally, I documented incident response scenarios such as blocked HTTP access, AWS region mismatch, Terraform subnet errors, ECR IAM permission issues, and ALB health check failures. This training gave me practical experience in infrastructure provisioning, monitoring, automation, CI/CD, Kubernetes, high availability, cost control, and incident response.

```
```

