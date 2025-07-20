# 🚀 DevOps Academy – Maven Web Application


Welcome to the hands-on DevOps Academy demo! This project is a Spring MVC web app (Maven-based, packaged as a WAR) showcasing a real-world, cloud-native CI/CD pipeline for Java developers and DevOps engineers.

**Note:** The application now targets **Jakarta EE 10 (Servlet&nbsp;6)** and is tested on **Apache Tomcat&nbsp;11**.

---

## 🏗️ What’s Included?

This repo demonstrates **end-to-end CI/CD** with:

- **Maven** – Build management
- **SonarQube** – Code quality & security scanning
- **Nexus** – Artifact repository (release & snapshot)
- **Docker** – Containerization
- **Apache Tomcat** – App server
- **Kubernetes** – Container orchestration
- **Jenkins** – CI/CD automation

---

## ⚡️ Quick Start: Automated Lab Setup

### 🛠️ Install DevOps Tools Automatically

Don’t waste hours on manual setup—**automated scripts are ready for you!**

- 👉 [DevOps-class-installation-scripts](https://github.com/m-pasima/DevOps-class-installation-scripts.git)  
  *Bash scripts to install Java, Maven, Docker, SonarQube, Nexus, Jenkins, and Tomcat on your Linux servers.*

  > **Best Practice:**  
  > Review each script before running. Use test VMs—don’t experiment on production.

### ☁️ One-Click AWS Lab with Terraform

Spin up an entire CI/CD environment (servers + tools) in AWS using Terraform:

- 👉 [terraform-aws-devops-lab](https://github.com/m-pasima/terraform-aws-devops-lab.git)  
  *Automated infrastructure-as-code to create EC2 servers and install SonarQube, Nexus, Jenkins, and Tomcat.*

  > **Warning:**  
  > This will provision AWS resources—costs may apply. Always run `terraform destroy` when finished to avoid surprises!

---

## 📂 Project Structure

```

maven-web-application/
├── src/
│   ├── main/java/com/mt/controller/HelloController.java
│   └── test/java/com/mt/controller/HelloControllerTest.java
├── pom.xml
├── Dockerfile
├── Jenkinsfile
└── k8s-deployment.yaml

````

---

## 🔥 Prerequisites

Before diving in, ensure you have:

- Java 8+
- Maven 3.8+
- Docker
- Jenkins (with Pipeline & Git plugins)
- A running Kubernetes cluster (minikube, EKS, AKS, GKE, etc.)
- SonarQube
- Nexus Repository Manager

**Tip:** Use the scripts/lab above to fast-track setup!

---

## 🏗️ Maven Build

```bash
mvn clean install
````

Creates `target/tesco.war`.

> Use `mvn clean verify` for strict, CI-friendly builds.

---

## 🔎 SonarQube Integration

Add to your `pom.xml`:

```xml
<properties>
  <sonar.host.url>http://<sonarqube-ip>:9000</sonar.host.url>
  <sonar.login>your-token</sonar.login>
</properties>
```

Run analysis:

```bash
mvn sonar:sonar
```

> **Store your SonarQube token securely**—use Jenkins credentials binding for pipelines.

---

## 📦 Nexus Integration

In `pom.xml` (for deploying builds):

```xml
<distributionManagement>
  <repository>
    <id>nexus</id>
    <url>http://<nexus-ip>:8081/repository/maven-releases/</url>
  </repository>
  <snapshotRepository>
    <id>nexus</id>
    <url>http://<nexus-ip>:8081/repository/maven-snapshots/</url>
  </snapshotRepository>
</distributionManagement>
```

Deploy:

```bash
mvn deploy
```

> Store Nexus credentials in Maven’s `settings.xml` and Jenkins secrets—**never commit secrets to Git!**

---

## 🐳 Docker Setup

### Dockerfile

```Dockerfile
# Example Dockerfile using Tomcat 11
FROM tomcat:11-jdk17-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
COPY target/tesco.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
```

Build & run locally:

```bash
docker build -t devops-academy .
docker run -p 8080:8080 devops-academy
```

---

## ☸️ Kubernetes Deployment

### k8s-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-academy-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: devops-academy
  template:
    metadata:
      labels:
        app: devops-academy
    spec:
      containers:
      - name: webapp
        image: your-dockerhub/devops-academy:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: devops-academy-service
spec:
  type: LoadBalancer
  selector:
    app: devops-academy
  ports:
  - port: 80
    targetPort: 8080
```

Apply to cluster:

```bash
kubectl apply -f k8s-deployment.yaml
```

> **Pro Tip:**
> Always use image tags (`:v1.0.0`, `${BUILD_NUMBER}`) instead of `latest` for predictable deployments.

---

## 🐘 PostgreSQL Setup

The application stores enquiries in PostgreSQL. Configure connection details using environment variables before starting Tomcat:

```bash
export DB_URL="jdbc:postgresql://<db-host>:5432/<db>"
export DB_USERNAME="postgres"
export DB_PASSWORD="your-password"
```

Pass these variables to `docker run` or your Kubernetes deployment so the webapp can connect to your database.

---

## 🔄 Jenkins Multibranch Pipeline Example

### Jenkinsfile

```groovy
pipeline {
    agent any

    tools {
        maven 'Maven 3.8.6'
        jdk 'Java 8'
    }

    environment {
        IMAGE_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checked out branch: ${env.BRANCH_NAME}"
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Code Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Publish Artifact') {
            steps {
                sh 'mvn deploy'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    dockerImage = docker.build("your-dockerhub/devops-academy:${env.IMAGE_TAG}")
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                branch 'main'
            }
            steps {
                withKubeConfig([credentialsId: 'kubeconfig-id']) {
                    sh 'kubectl apply -f k8s-deployment.yaml'
                }
            }
        }
    }
}
```

> **Multibranch Pipelines:**
> Jenkins will automatically create jobs for every branch with a `Jenkinsfile`—perfect for modern Git workflows.

---

## 🗂️ Maven Local Repository (Optional)

To use a shared Maven repo (helpful in CI/CD):

Edit `/opt/maven/conf/settings.xml`:

```xml
<localRepository>/opt/maven/repo</localRepository>
```

---

## 🦾 Best Practices & Maintenance

* **Always use Jenkins/K8s secrets for credentials.**

* **Delete stale remote branches** to keep your repo healthy:

  ```bash
  git push origin --delete <branch-name>
  ```

* **Protect key branches** via branch protection rules in your Git hosting platform.

* **Monitor your build nodes**—label agents for special tools (e.g., Docker, Java, Node.js).

---

## 🆘 Support & Contribution

* Found a bug or want to improve something?
  [Open an issue](https://github.com/m-pasima/maven-web-app-demo/issues) or connect with [Pasima](https://m-pasima.github.io/The-DevOps-Academy/).
* For installation help, see
  [DevOps-class-installation-scripts](https://github.com/m-pasima/DevOps-class-installation-scripts.git)
  and
  [terraform-aws-devops-lab](https://github.com/m-pasima/terraform-aws-devops-lab.git).

---

## © DevOps Academy

```

