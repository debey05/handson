pipeline {
    agent any

    tools {
        maven 'maven'     // <-- This is your builder, name must match Jenkins tool name
    }

    environment {
        APP_NAME = "demo-app"
        IMAGE_NAME = "demo-app-image"
        CONTAINER_NAME = "demo-app-container"
        DOCKERHUB_USER = "your-dockerhub-username"
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
                echo "⚙️ Building project using Maven builder..."
                sh "mvn clean package -DskipTests"
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Run Container') {
            steps {
                echo "🚀 Running container..."
                sh """
                docker ps -q --filter name=${CONTAINER_NAME} | grep -q . && docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME} || true
                docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${IMAGE_NAME}:latest
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
