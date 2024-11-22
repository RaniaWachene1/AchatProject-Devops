pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerHub'
        GIT_CREDENTIALS_ID = 'git-cred'
        IMAGE_REPO_BACKEND = 'raniawachene/tpachat-backend'
        IMAGE_REPO_FRONTEND = 'raniawachene/tpachat-frontend'
        NEXUS_URL = 'http://193.95.57.13:8081/repository/maven-releases/'
        NEXUS_CREDENTIALS_ID = 'nexus-cred'
    }

    stages {

        // Git Checkout - Backend
        stage("Git Checkout Backend") {
            steps {
                dir('backend') {
                    git branch: 'main', credentialsId: "${GIT_CREDENTIALS_ID}", url: 'https://github.com/RaniaWachene1/AchatProject-Devops.git'
                }
                echo 'Backend checkout completed successfully.'
            }
        }

        // Git Checkout - Frontend
        stage("Git Checkout Frontend") {
            steps {
                dir('frontend') {
                    git branch: 'main', credentialsId: "${GIT_CREDENTIALS_ID}", url: 'https://github.com/RaniaWachene1/AchatProject-Front-Devops.git'
                }
                echo 'Frontend checkout completed successfully.'
            }
        }
  // Update the version in pom.xml
        stage('Update Version') {
            steps {
                dir('backend') {
                    script {
                        def version = "1.0.${env.BUILD_NUMBER}"
                        sh "mvn versions:set -DnewVersion=${version} -DgenerateBackupPoms=false"
                        echo "Updated version in pom.xml to ${version}."
                    }
                }
            }
        }
        // Clean and Build Backend
        stage('Backend - Maven Clean & Package') {
            steps {
                dir('backend') {
                    sh 'mvn clean package'
                    echo 'Backend clean and package completed successfully.'
                }
            }
        }

        // Build & Tag Docker Image for Backend
   stage('Build & Tag Docker Image') {
       steps {
           script {
               def version = "1.0.${env.BUILD_NUMBER}"
               def jarFile = "target/tpAchatProject-${version}.jar"
               def dockerImage = "raniawachene/tpachat-backend:${env.BUILD_NUMBER}"

               withDockerRegistry(credentialsId: 'dockerHub') {
                   sh """
                       docker build --build-arg JAR_FILE=${jarFile} -t ${dockerImage} .
                   """
                   echo "Docker image ${dockerImage} built successfully."
               }
           }
       }
   }


        // Push Backend Docker Image
        stage('Backend - Push Docker Image') {
            steps {
                dir('backend') {
                    script {
                        def dockerImage = "${IMAGE_REPO_BACKEND}:${env.BUILD_NUMBER}"
                        withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                            sh "docker push ${dockerImage}"
                            echo "Backend Docker image ${dockerImage} pushed successfully."
                        }
                    }
                }
            }
        }

        // Clean and Build Frontend
        stage('Frontend - NPM Build') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                    sh 'npm run build --prod'
                    echo 'Frontend build completed successfully.'
                }
            }
        }

        // Build & Tag Docker Image for Frontend
        stage('Frontend - Build & Tag Docker Image') {
            steps {
                dir('frontend') {
                    script {
                        def dockerImage = "${IMAGE_REPO_FRONTEND}:latest"
                        withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                            sh "docker build -t ${dockerImage} ."
                            echo "Frontend Docker image ${dockerImage} built and tagged successfully."
                        }
                    }
                }
            }
        }

        // Push Frontend Docker Image
        stage('Frontend - Push Docker Image') {
            steps {
                dir('frontend') {
                    script {
                        def dockerImage = "${IMAGE_REPO_FRONTEND}:latest"
                        withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                            sh "docker push ${dockerImage}"
                            echo "Frontend Docker image ${dockerImage} pushed successfully."
                        }
                    }
                }
            }
        }

        // Docker Compose - Deploy Both Frontend and Backend
        stage('Docker Compose') {
            steps {
                script {
                    sh 'docker-compose down || true'
                    sh 'docker-compose up -d'
                    echo 'Docker Compose deployment completed successfully.'
                }
            }
        }
    }

    post {
        success {
            echo 'Build, Test, and Deployment completed successfully.'
        }
        failure {
            echo 'Build failed. Please check the logs for details.'
        }
    }
}
