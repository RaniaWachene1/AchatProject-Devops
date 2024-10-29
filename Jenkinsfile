pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerHub'
        GIT_CREDENTIALS_ID = 'git-cred'
        IMAGE_REPO = 'raniawachene/tpachat'
        NEXUS_URL = 'http://193.95.57.13:8081/repository/maven-releases/'
        NEXUS_CREDENTIALS_ID = 'nexus-cred'
    }

    parameters {
        string(name: 'newBuildNumber', defaultValue: "${BUILD_NUMBER}", description: 'The new build number to be deployed')
    }

    stages {

        stage("Git Checkout") {
            steps {
                git branch: 'main', credentialsId: "${GIT_CREDENTIALS_ID}", url: 'https://github.com/RaniaWachene1/AchatProject-Devops.git'
                echo 'Checkout completed successfully.'
            }
        }

        // Update the version in the pom.xml using build number
        stage('Update Version') {
            steps {
                script {
                    def newBuildNumber = "${params.newBuildNumber}"
                    def newVersion = "1.0.${newBuildNumber}"

                    // Update the pom.xml version dynamically
                    sh """
                        mvn versions:set -DnewVersion=${newVersion} -DgenerateBackupPoms=false
                    """
                    echo "Updated version to ${newVersion}."
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
                    def newBuildNumber = "${params.newBuildNumber}"
                    def newVersion = "1.0.${newBuildNumber}"

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
                    def dockerTag = "${params.newBuildNumber}"
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
                    def dockerTag = "${params.newBuildNumber}"
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
                    def oldTag = "${params.newBuildNumber.toInteger() - 1}"
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
