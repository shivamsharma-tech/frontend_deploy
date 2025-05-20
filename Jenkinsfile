pipeline {
    agent any

    parameters {
        string(name: 'GIT_COMMIT', defaultValue: 'main', description: 'Git branch or commit hash to deploy')
    }

    environment {
        DOCKER_CREDENTIALS_ID = 'Docker-access'            // Docker Hub credential ID
        DOCKER_IMAGE = 'shivamsharam/frontend_deploy'      // Docker image name
        EC2_CREDENTIALS = 'ubuntu'                         // EC2 SSH key credential ID
        EC2_USER = 'ubuntu'                                // EC2 username
        EC2_IP = '51.20.95.8'                              // EC2 public IP
    }

    stages {
        stage('Test Docker Access') {
            steps {
                sh 'docker ps'
            }
        }

        stage('Checkout SCM') {
            steps {
                git branch: "${params.GIT_COMMIT}", url: 'https://github.com/shivamsharma-tech/frontend_deploy'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .
                    docker tag $DOCKER_IMAGE:$BUILD_NUMBER $DOCKER_IMAGE:latest
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                sh '''
                    docker push $DOCKER_IMAGE:$BUILD_NUMBER
                    docker push $DOCKER_IMAGE:latest
                '''
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(credentials: [env.EC2_CREDENTIALS]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_IP '
                            echo "➡ Pulling latest Docker image: $DOCKER_IMAGE:$BUILD_NUMBER" &&
                            sudo docker pull $DOCKER_IMAGE:$BUILD_NUMBER &&

                            echo "🛑 Stopping old container if running..." &&
                            sudo docker stop frontend_deploy || true &&
                            sudo docker rm frontend_deploy || true &&

                            echo "🚀 Starting new container..." &&
                            sudo docker run -d --name frontend_deploy -p 4000:4000 -p 5000:5000 -e PORTS=4000,5000 $DOCKER_IMAGE:$BUILD_NUMBER &&

                            echo "✅ Container deployed successfully."
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! Docker tag: $BUILD_NUMBER"
        }
        failure {
            echo '❌ Deployment failed. Check logs.'
        }
    }
}
