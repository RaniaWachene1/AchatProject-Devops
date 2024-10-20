pipeline {
    agent any
    stages {
        stage("Git Checkout"){
            steps {
            git branch: 'main',
             credentialsId: 'git-cred',
              url: 'https://github.com/RaniaWachene1/AchatProject-Devops.git'
                echo 'checkout stage'
            }
        }

        stage ('maven clean') {
      steps {
        sh 'mvn clean'
        echo 'Build stage done'
      }
    }

        stage("compile Project"){
        steps {
            sh 'mvn compile'
            echo 'compile stage done'
            }
        }
        stage("unit tests"){
            steps {
                 sh 'mvn test'
                  echo 'unit tests stage done'
            }
        }

        stage('maven package') {
             steps {
               sh 'mvn package'
          }
   }
}
}