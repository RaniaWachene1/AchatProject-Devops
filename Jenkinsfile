pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerHub'  // Docker Hub credentials
        GIT_CREDENTIALS_ID = 'git-cred'      // Git credentials
        DOCKER_IMAGE = 'raniawachene/tpachat:latest'  // Docker image tag
    }

    stages {
        stage("Git Checkout") {
            steps {
                git branch: 'main', credentialsId: "${GIT_CREDENTIALS_ID}", url: 'https://github.com/RaniaWachene1/AchatProject-Devops.git'
                echo 'Checkout completed successfully.'
            }
        }

        stage('Maven Clean') {
            steps {
                sh 'mvn clean'
                echo 'Clean stage completed successfully.'
            }
        }

        stage("Compile Project") {
            steps {
                sh 'mvn compile'
                echo 'Compilation completed successfully.'
            }
        }

        stage("Run Unit Tests") {
            steps {
                sh 'mvn test'
                echo 'Unit tests completed successfully.'
            }
        }

        stage('Maven Package') {
            steps {
                sh 'mvn package'
                echo 'Package stage completed successfully.'
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                script {
                    // Login to Docker Hub and build the image
                    withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                        sh "docker build -t ${DOCKER_IMAGE} ."
                        echo "Docker image ${DOCKER_IMAGE} built and tagged successfully."
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                        sh "docker push ${DOCKER_IMAGE}"
                        echo "Docker image ${DOCKER_IMAGE} pushed to Docker Hub successfully."
                    }
                }
            }
        }
    }
}
