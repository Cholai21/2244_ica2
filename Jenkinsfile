pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'your-dockerhub-username/static-website'
        DOCKER_TAG = "develop-${env.BUILD_ID}"
        WEB_SERVER = 'web-server-ip'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'develop', url: 'https://github.com/Cholai21/2244_ica2.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG .'
                sh 'docker build -t $DOCKER_IMAGE:latest .'
            }
        }
        stage('Push Docker Image') {
            steps {
                sh 'docker push $DOCKER_IMAGE:$DOCKER_TAG'
                sh 'docker push $DOCKER_IMAGE:latest'
            }
        }
        stage('Deploy to Web Server') {
            steps {
                sh """
                ssh user@$WEB_SERVER "
                docker pull $DOCKER_IMAGE:$DOCKER_TAG &&
                docker run -d -p 8081:80 --name static-website-dev $DOCKER_IMAGE:$DOCKER_TAG"
                """
            }
        }
        stage('Test Deployment') {
            steps {
                sh "curl -I http://$WEB_SERVER:8081"
            }
        }
    }
}
