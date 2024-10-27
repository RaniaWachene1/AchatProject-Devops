pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerHub'
        GIT_CREDENTIALS_ID = 'git-cred'
        IMAGE_REPO = 'raniawachene/tpachat'
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
         stage('SonarQube Analysis') {
                    steps {
                        withSonarQubeEnv('SonarQube-Server') { // Use the name you gave in Jenkins configuration
                            sh 'mvn sonar:sonar \
                                -Dsonar.projectKey=tpAchat \
                                -Dsonar.host.url=http://193.95.57.13:9000 \
                                -Dsonar.login=sonarqube-cred'
                        }
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
                    def dockerTag = "${BUILD_NUMBER}"
                    def dockerImage = "${IMAGE_REPO}:${dockerTag}"
                    withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                        sh "docker build -t ${dockerImage} ."
                        echo "Docker image ${dockerImage} built and tagged successfully."
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def dockerTag = "${BUILD_NUMBER}"
                    def dockerImage = "${IMAGE_REPO}:${dockerTag}"
                    withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                        sh "docker push ${dockerImage}"
                        echo "Docker image ${dockerImage} pushed to Docker Hub successfully."
                    }
                }
            }
        }



        stage('Clean Old Docker Images from Registry') {
            steps {
                script {
                    def oldTag = "${BUILD_NUMBER - 1}"
                    def oldImage = "${IMAGE_REPO}:${oldTag}"
                    withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                        // Try removing the previous Docker image if it exists
                        sh "docker rmi ${oldImage} || echo 'Previous image ${oldImage} not found.'"
                    }
                }
            }
        }
    }
}
