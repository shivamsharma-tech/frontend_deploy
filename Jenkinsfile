pipeline {
    agent any

    parameters {
        string(name: 'GIT_COMMIT', defaultValue: 'main', description: 'Git branch or commit hash to deploy')
        string(name: 'DOCKER_TAG', defaultValue: '', description: 'Optional: Docker tag to deploy (e.g. 26). Leave blank to build a new one')
    }

    environment {
        DOCKER_CREDENTIALS = credentials('Docker-access')
        DOCKER_IMAGE = 'shivamsharam/frontend_deploy'
        EC2_CREDENTIALS = 'ubuntu'
        EC2_USER = 'ubuntu'
        EC2_IP = '51.20.95.8'
    }

    stages {
        stage('Test Docker Access') {
            when { expression { params.DOCKER_TAG == "28" } }
            steps {
                sh 'docker ps'
            }
        }

        stage('Checkout SCM') {
            when { expression { params.DOCKER_TAG == "28" } }
            steps {
                git branch: "${params.GIT_COMMIT}", url: 'https://github.com/shivamsharma-tech/frontend_deploy'
            }
        }

        stage('Build Docker Image') {
            when { expression { params.DOCKER_TAG == "28" } }
            steps {
                sh """
                    docker build -t $DOCKER_IMAGE:${env.BUILD_NUMBER} .
                    docker tag $DOCKER_IMAGE:${env.BUILD_NUMBER} $DOCKER_IMAGE:latest
                """
            }
        }

        stage('Login to Docker Hub') {
            when { expression { params.DOCKER_TAG == "28" } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'Docker-access', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin'
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            when { expression { params.DOCKER_TAG == "28" } }
            steps {
                sh """
                    docker push $DOCKER_IMAGE:${env.BUILD_NUMBER}
                    docker push $DOCKER_IMAGE:latest
                """
            }
        }
        

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(credentials: [env.EC2_CREDENTIALS]) {
                    script {
                        def tag = params.DOCKER_TAG ?: env.BUILD_NUMBER
                        sh """
                            ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_IP '
                                sudo docker pull $DOCKER_IMAGE:${tag} &&
                                sudo docker stop frontend_deploy || true &&
                                sudo docker rm frontend_deploy || true &&
                                sudo docker run -d --name frontend_deploy -p 4000:4000 -p 5000:5000 -e PORTS=4000,5000 $DOCKER_IMAGE:${tag}
                            '
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                echo "✅ Deployment successful! Docker tag: ${params.DOCKER_TAG ?: env.BUILD_NUMBER}"
            }
        }
        failure {
            echo '❌ Deployment failed. Check logs.'
        }
    }
}
