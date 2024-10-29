pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerHub'
        GIT_CREDENTIALS_ID = 'git-cred'
        IMAGE_REPO = 'raniawachene/tpachat'
        NEXUS_URL = 'http://193.95.57.13:8081/repository/maven-releases/'
        NEXUS_CREDENTIALS_ID = 'nexus-cred'
    }

    stages {

        // Git Checkout
        stage("Git Checkout") {
            steps {
                git branch: 'main', credentialsId: "${GIT_CREDENTIALS_ID}", url: 'https://github.com/RaniaWachene1/AchatProject-Devops.git'
                echo 'Checkout completed successfully.'
            }
        }

        // Update the version in the pom.xml using the build number automatically
        stage('Update Version') {
            steps {
                script {
            def version = "1.0.${env.BUILD_NUMBER}"
              sh "mvn versions:set -DnewVersion=${version} -DgenerateBackupPoms=false"
                }
            }
        }

        // Clean the project
        stage('Maven Clean') {
            steps {
                sh 'mvn clean'
                echo 'Clean stage completed successfully.'
            }
        }

        // Compile the project
        stage("Compile Project") {
            steps {
                sh 'mvn compile'
                echo 'Compilation completed successfully.'
            }
        }

        // Run unit tests
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
                        echo 'SonarQube analysis completed successfully.'
                    }
                }
            }
        }

        // Package the application
        stage('Maven Package') {
            steps {
                sh 'mvn package'
                echo 'Package stage completed successfully.'
            }
        }

        // Deploy to Nexus Repository
        stage('Deploy to Nexus') {
            steps {
                script {
                    def newVersion = "1.0.${env.BUILD_NUMBER}"

                    withCredentials([usernamePassword(credentialsId: "${NEXUS_CREDENTIALS_ID}", passwordVariable: 'NEXUS_PASS', usernameVariable: 'NEXUS_USER')]) {
                        sh """
                            mvn deploy:deploy-file \
                            -DgroupId=com.esprit.examen \
                            -DartifactId=tpAchatProject \
                            -Dversion=${newVersion} \
                            -Dpackaging=jar \
                            -Dfile=target/tpAchatProject-${newVersion}.jar \
                            -DrepositoryId=nexus-repo \
                            -Durl=${NEXUS_URL} \
                            -DgeneratePom=true
                        """
                        echo "Deployed version ${newVersion} to Nexus."
                    }
                }
            }
        }

        // Build and tag Docker image
        stage('Build & Tag Docker Image') {
            steps {
                script {
                    def dockerTag = "${env.BUILD_NUMBER}"
                    def dockerImage = "${IMAGE_REPO}:${dockerTag}"
                    withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                        sh "docker build -t ${dockerImage} ."
                        echo "Docker image ${dockerImage} built and tagged successfully."
                    }
                }
            }
        }

        // Push Docker image to Docker Hub
        stage('Push Docker Image') {
            steps {
                script {
                    def dockerTag = "${env.BUILD_NUMBER}"
                    def dockerImage = "${IMAGE_REPO}:${dockerTag}"
                    withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                        sh "docker push ${dockerImage}"
                        echo "Docker image ${dockerImage} pushed to Docker Hub successfully."
                    }
                }
            }
        }

        // Clean old Docker images from the registry
        stage('Clean Old Docker Images from Registry') {
            steps {
                script {
                    def oldTag = "${env.BUILD_NUMBER.toInteger() - 1}"
                    def oldImage = "${IMAGE_REPO}:${oldTag}"
                    withDockerRegistry(credentialsId: "${DOCKER_CREDENTIALS_ID}") {
                        sh "docker rmi ${oldImage} || echo 'Previous image ${oldImage} not found.'"
                        echo "Old Docker image ${oldImage} removed."
                    }
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
