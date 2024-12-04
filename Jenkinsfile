pipeline {
    agent any
    environment {
        scannerHome = tool 'sonar-scanner'
    }

    stages {
        stage('GIT Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/ishurusia5/react-landmarks.git'
            }
        }

        stage('Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--noupdate -s ./ -f HTML -o ./', odcInstallation: 'DC'
            }
        }

        stage('SonarQube') {
            steps {
                withSonarQubeEnv('sonar-scanner') {
                    sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=sonar \
                        -Dsonar.projectName=sonar
                    """
                    echo 'SonarQube Analysis Completed'
                }
            }
        }

        stage('Docker Build & Tag') {
            steps {
                withDockerRegistry(credentialsId: 'nexus', url: 'http://localhost:8082') {
                    sh "docker build -t localhost:8082/react:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy image localhost:8082/react:${BUILD_NUMBER}"
            }
        }

        stage('Docker Push') {
            steps {
                withDockerRegistry(credentialsId: 'nexus', url: 'http://localhost:8082') {
                    sh "docker push localhost:8082/react:${BUILD_NUMBER}"
                }
            }
        }

        stage('Cleanup Old Docker Images') {
            steps {
                script {
                    sh """
                    # Fetch the list of images tagged with ishurusia/react
                    docker images localhost:8082/react --format '{{.Tag}}' | sort -nr | tail -n +4 | xargs -I {} docker rmi ishurusia/react:{}
                    """
                    echo "Older images deleted, keeping only the latest 3."
                }
            }
        }

        stage('Deploy') {
            steps {
                sh "docker-compose up -d"
            }
        }
    }
}
