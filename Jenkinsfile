pipeline {
    agent any

    // Environment variables
    environment {
        DOCKER_CREDENTIALS_ID = 'dockerHub'
        GIT_CREDENTIALS_ID = 'git-cred'
        IMAGE_REPO = 'raniawachene/tpachat'
        SONAR_HOST_URL = 'http://193.95.57.13:9000'
        NEXUS_URL = 'http://193.95.57.13:8081/repository/maven-releases/'
    }

    parameters {
        string(name: 'newVersion', defaultValue: '', description: 'The new version to be deployed')
    }

    stages {

        // Git Checkout
        stage("Git Checkout") {
            steps {
                script {
                    git branch: 'main', credentialsId: "${GIT_CREDENTIALS_ID}", url: 'https://github.com/RaniaWachene1/AchatProject-Devops.git'
                    echo 'Git checkout completed successfully.'
                }
            }
        }

        // Maven Clean
        stage('Maven Clean') {
            steps {
                script {
                    sh 'mvn clean'
                    echo 'Maven clean completed successfully.'
                }
            }
        }

        // Compile Project
        stage("Compile Project") {
            steps {
                script {
                    sh 'mvn compile'
                    echo 'Compilation completed successfully.'
                }
            }
        }

        // Run Unit Tests
        stage("Run Unit Tests") {
            steps {
                script {
                    sh 'mvn test'
                    echo 'Unit tests completed successfully.'
                }
            }
        }

        // SonarQube Analysis
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    withCredentials([string(credentialsId: 'sonarqube-cred', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            mvn sonar:sonar \
                            -Dsonar.projectKey=tpAchat \
                            -Dsonar.host.url=${SONAR_HOST_URL} \
                            -Dsonar.login=$SONAR_TOKEN
                        '''
                        echo 'SonarQube analysis completed successfully.'
                    }
                }
            }
        }

        // Maven Package
        stage('Maven Package') {
            steps {
                script {
                    sh 'mvn package'
                    echo 'Maven package completed successfully.'
                }
            }
        }

        // Nexus Deploy
        stage("Nexus Deploy") {
            steps {
                script {
                    if (params.newVersion?.trim()) {
                        sh "mvn deploy:deploy-file -DgroupId=com.esprit.examen -DartifactId=tpAchatProject -Dversion=${params.newVersion} -DgeneratePom=true -Dpackaging=jar -DrepositoryId=deploymentRepo -Durl=${NEXUS_URL} -Dfile=target/tpAchatProject-${params.newVersion}.jar"
                        echo "Nexus deployment successful for version ${params.newVersion}."
                    } else {
                        error("New version is not set. Cannot deploy to Nexus.")
                    }
                }
            }
        }

        // Build & Tag Docker Image
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

        // Push Docker Image to Registry
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

        // Clean Old Docker Images from Registry
        stage('Clean Old Docker Images from Registry') {
            steps {
                script {
                    def oldTag = "${BUILD_NUMBER.toInteger() - 1}"
                    def oldImage = "${IMAGE_REPO}:${oldTag}"
                    withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                        sh "docker rmi ${oldImage} || echo 'Previous image ${oldImage} not found.'"
                        echo "Old Docker image ${oldImage} removed."
                    }
                }
            }
        }
    }

    // Post-build actions
    post {
        success {
            echo 'Build, Test, and Deployment completed successfully.'
        }
        failure {
            echo 'Build failed. Please check the logs for details.'
        }
    }
}
