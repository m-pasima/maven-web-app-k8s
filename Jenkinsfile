pipeline {
    agent any

    tools {
        maven 'maven3.9.9'
    }


    stages {
        stage('Clone Code') {
            steps {

                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/m-pasima/maven-web-app-demo.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh "mvn clean package"
            }
        }

        stage('Sonar Scan') {
            steps {
                sh "mvn verify sonar:sonar"
            }
        }

        stage('Upload Build Artifacts') {
            steps {
                sh "mvn deploy"
            }
        }

        stage('Deploy to Dev') {
            when {
                branch 'dev'
            }
            steps {
                echo 'Deploying to Dev...'

            }
        }

        stage('Deploy to Stage') {
            when {
                branch 'stage'
            }
            steps {
                echo 'Deploying to Stage...'

            }
        }

        stage('Manual Approval & Deploy to Prod') {
            when {
                branch 'main'
            }
            steps {
                script {
                    input message: "Approve or Deny deployment to Production"
                }
             
                deploy adapters: [tomcat9(alternativeDeploymentContext: '', credentialsId: 'tomcat-creds', path: '', url: 'http://35.179.144.183:8080/')], contextPath: 'tesco', war: '**/*.war'
            }
        }
    }
}

