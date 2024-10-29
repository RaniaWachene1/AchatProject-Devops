pipeline {
    agent any

    // Build parameters
    parameters {
        string(name: 'newVersion', defaultValue: '1.0.0', description: 'Version for Nexus deployment')
    }

    // Environment variables
    environment {
        DOCKER_CREDENTIALS_ID = 'dockerHub'
        GIT_CREDENTIALS_ID = 'git-cred'
        IMAGE_REPO = 'raniawachene/tpachat'
    }

    stages {

        // Git Checkout
        stage("Git Checkout") {
            steps {
                git branch: 'main', credentialsId: "${GIT_CREDENTIALS_ID}", url: 'https://github.com/RaniaWachene1/AchatProject-Devops.git'
                echo 'Checkout completed successfully.'
            }
        }

        // Maven Clean
        stage('Maven Clean') {
            steps {
                sh 'mvn clean'
                echo 'Clean stage completed successfully.'
            }
        }

        // Compile Project
        stage("Compile Project") {
            steps {
                sh 'mvn compile'
                echo 'Compilation completed successfully.'
            }
        }

        // Run Unit Tests
        stage("Run Unit Tests") {
            steps {
                sh 'mvn test'
                echo 'Unit tests completed successfully.'
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
                            -Dsonar.host.url=http://193.95.57.13:9000 \
                            -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        // Maven Package
        stage('Maven Package') {
            steps {
                sh 'mvn package'
                echo 'Package stage completed successfully.'
            }
        }

        // Nexus Deploy
        stage("Nexus Deploy") {
            steps {
                script {
                    if (params.newVersion) {
                        sh "mvn deploy:deploy-file -DgroupId=com.esprit.examen -DartifactId=tpAchatProject -Dversion=${params.newVersion} -DgeneratePom=true -Dpackaging=jar -DrepositoryId=deploymentRepo -Durl=http://193.95.57.13:8081/repository/maven-releases/ -Dfile=target/tpAchatProject-${params.newVersion}.jar"
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
                    def oldTag = "${BUILD_NUMBER - 1}"
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
