pipeline {
    environment {
        ECR_REGISTRY = "535597585675.dkr.ecr.ap-northeast-2.amazonaws.com"
        ECR_REPOSITORY = "product_ci"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    agent any
    stages {
        stage('Checkout') {
            steps {
                // Git 리포지토리에서 코드를 체크아웃합니다.
                checkout scm
            }
        }
        stage('Build and push image with Kaniko') {
            steps {
                // AWS 자격 증명을 설정합니다. 'aws-credentials'는 Jenkins 내에 설정된 자격증명 ID입니다.
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'product_ci_aws-credentials']]) {
                    // Kaniko executor를 사용하여 이미지를 빌드하고 ECR에 푸시합니다.
                    sh """
                    /kaniko/executor \
                      --context https://github.com/seyoon12/product_ci_eks \
                      --dockerfile https://github.com/seyoon12/product_ci_eks/Dockerfile \
                      --destination ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} \
                      --destination ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                    """
                }
            }
        }
    }
    post {
        success {
            // 성공적으로 빌드가 완료되면 실행됩니다.
            echo 'Image build and push successful'
        }
        failure {
            // 빌드 실패 시 실행됩니다.
            echo 'Image build or push failed'
        }
    }
}
