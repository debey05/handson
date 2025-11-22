pipeline {
    agent any

    tools {
        maven 'maven'
    }

    environment {
        APP_NAME = "jenkinsdemo-app"
        IMAGE_NAME = "deborahdel/jenkinsbuild2"
        CONTAINER_NAME = "jenkinsdemo-app-container"
        DOCKERHUB_USER = "deborahdel"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📦 Checking out source code..."
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                echo "⚙️ Building project using Maven..."
                sh "mvn clean package -DskipTests"
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."

                sh '''
                    echo "🔧 Checking if Docker is installed..."
                    if ! command -v docker &> /dev/null; then
                        echo "🐳 Docker not found. Installing..."
                        sudo apt update -y
                        sudo apt install docker.io -y
                        sudo systemctl enable docker
                        sudo systemctl start docker
                    else
                        echo "✔ Docker already installed."
                    fi

                    echo "🔑 Adding Jenkins user to docker group..."
                    sudo usermod -aG docker jenkins || true

                    echo "🔧 Fixing Docker socket permissions..."
                    sudo chmod 666 /var/run/docker.sock || true

                    echo "🔄 Restarting Docker..."
                    sudo systemctl restart docker || true
                '''

                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                echo "📤 Pushing image to Docker Hub..."

                withCredentials([string(credentialsId: 'dockerhub_token', variable: 'DOCKER_TOKEN')]) {
                    sh """
                    echo "🔐 Logging into Docker Hub..."
                    echo "${DOCKER_TOKEN}" | docker login -u "${DOCKERHUB_USER}" --password-stdin
                    
                    echo "🏷 Tagging image..."
                    # docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}

                    echo "📤 Pushing image..."
                    docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Run Container') {
            steps {
                echo "🚀 Running container..."
                sh """
                docker ps -q --filter name=${CONTAINER_NAME} | grep -q . && \
                docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME} || true

                docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully! App running on port 8080."
            sh 'docker ps'
        }
        failure {
            echo "❌ Pipeline failed. Check logs!"
        }
    }
}
