pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'pavala/static-website' // Docker Hub repo
        DOCKER_TAG = "develop-${env.BUILD_ID}" // Tag for the Docker image
        DOCKER_SERVER = '15.156.65.109' // Docker server IP
        SSH_CREDENTIALS_ID = 'docker-server-ssh' // SSH credentials for Docker server
        DOCKER_HUB_CREDENTIALS_ID = 'docker-hub-credentials' // Docker Hub credentials
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Pull the latest code from GitHub
                git branch: 'develop', url: 'https://github.com/Cholai21/2244_ica2.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sshagent([SSH_CREDENTIALS_ID]) {
                    // Copy code to Docker server
                    sh """
                    ssh root@$DOCKER_SERVER "
                    mkdir -p /tmp/2244_ica2 &&
                    rm -rf /tmp/2244_ica2/*"
                    """
                    sh "scp -r ./* root@$DOCKER_SERVER:/tmp/2244_ica2/"

                    // Build Docker image on the Docker server
                    sh """
                    ssh root@$DOCKER_SERVER "
                    cd /tmp/2244_ica2 &&
                    docker build -t $DOCKER_IMAGE:$DOCKER_TAG . &&
                    docker build -t $DOCKER_IMAGE:latest .
                    "
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                // Use Docker Hub credentials to push the image
                withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDENTIALS_ID, 
                                                 usernameVariable: 'DOCKER_USER', 
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sshagent([SSH_CREDENTIALS_ID]) {
                        sh """
                        ssh root@$DOCKER_SERVER "
                        docker login -u $DOCKER_USER -p $DOCKER_PASS &&
                        docker push $DOCKER_IMAGE:$DOCKER_TAG &&
                        docker push $DOCKER_IMAGE:latest
                        "
                        """
                    }
                }
            }
        }

        stage('Deploy Docker Container') {
            steps {
                sshagent([SSH_CREDENTIALS_ID]) {
                    // Deploy the Docker container on the Docker server
                    sh """
                    ssh root@$DOCKER_SERVER "
                    docker pull $DOCKER_IMAGE:$DOCKER_TAG &&
                    docker stop static-website-dev || true &&
                    docker rm static-website-dev || true &&
                    docker run -d -p 8081:80 --name static-website-dev $DOCKER_IMAGE:$DOCKER_TAG
                    "
                    """
                }
            }
        }

        stage('Test Deployment') {
            steps {
                // Test if the deployment is successful
                sh "curl -I http://$DOCKER_SERVER:8081"
            }
        }
    }

    post {
        always {
            echo 'Cleaning workspace...'
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
