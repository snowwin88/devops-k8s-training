
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

