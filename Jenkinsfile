pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('Docker-access')  // Jenkins credential ID for Docker Hub
        DOCKER_IMAGE = 'shivamsharam/frontend_deploy' // Docker image name
        EC2_CREDENTIALS = 'ubuntu' // Jenkins credential ID for EC2 private key
        EC2_USER = 'ubuntu' // or 'ubuntu' depending on your AMI
        EC2_IP = '13.51.193.141' // Replace with your EC2 instance public IP
    }

    stages {
        stage('Test Docker Access') {
            steps {
                sh 'docker ps'
            }
        }

        stage('Checkout SCM') {
            steps {
                git url: 'https://github.com/shivamsharma-tech/frontend_deploy', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "Docker-access", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                sh 'docker push $DOCKER_IMAGE:latest'
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(credentials: ["$EC2_CREDENTIALS"]) {
                    sh '''
ssh -o StrictHostKeyChecking=no ubuntu@13.51.193.141 "
    sudo docker pull shivamsharam/frontend_deploy &&
    sudo docker stop frontend_deploy || true &&
    sudo docker rm frontend_deploy || true &&
    sudo docker run -d --name frontend_deploy -p 4000:4000 -p 5000:5000 -e PORTS=4000,5000 shivamsharam/frontend_deploy:latest
"
'''
                }
            }
        }
        
    }

    post {
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Deployment failed. Check logs.'
        }
    }
}
