pipeline {
    environment {
        ECR_REGISTRY = '535597585675.dkr.ecr.ap-northeast-2.amazonaws.com'
        IMAGE_TAG = 'latest'
        REPO_NAME = 'jenkinsforecs' // 단순한 리포지토리 이름
    }

    agent any

    stages {
        stage('Checkout') {
            steps {
                git "https://github.com/seyoon12/${REPO_NAME}.git"
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Kaniko 컨테이너 실행 및 ECR로 이미지 푸시
                    sh """
                    /kaniko/executor \
                        --context . \
                        --dockerfile Dockerfile \
                        --destination ${ECR_REGISTRY}/${REPO_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
    }
}
