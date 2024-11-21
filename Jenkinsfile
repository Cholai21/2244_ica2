pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'your-dockerhub-username/static-website'
        DOCKER_TAG = "develop-${env.BUILD_ID}"
        DOCKER_SERVER = 'root@15.156.65.109'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'develop', url: 'https://github.com/Cholai21/2244_ica2.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                ssh $DOCKER_SERVER "
                mkdir -p /tmp/2244_ica2 &&
                rm -rf /tmp/2244_ica2/* &&
                exit"
                """
                sh "scp -r ./* $DOCKER_SERVER:/tmp/2244_ica2/"
                sh """
                ssh $DOCKER_SERVER "
                cd /tmp/2244_ica2 &&
                docker build -t $DOCKER_IMAGE:$DOCKER_TAG . &&
                docker build -t $DOCKER_IMAGE:latest .
                "
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                ssh $DOCKER_SERVER "
                docker push $DOCKER_IMAGE:$DOCKER_TAG &&
                docker push $DOCKER_IMAGE:latest
                "
                """
            }
        }

        stage('Deploy to Web Server') {
            steps {
                sh """
                ssh $DOCKER_SERVER "
                docker pull $DOCKER_IMAGE:$DOCKER_TAG &&
                docker stop static-website-dev || true &&
                docker rm static-website-dev || true &&
                docker run -d -p 8081:80 --name static-website-dev $DOCKER_IMAGE:$DOCKER_TAG
                "
                """
            }
        }

        stage('Test Deployment') {
            steps {
                sh "curl -I http://15.156.65.109:8081"
            }
        }
    }
}
