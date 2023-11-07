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
                // Git 리포지토리에 Git Credentials를 사용하여 코드를 체크아웃합니다.
                checkout([$class: 'GitSCM', 
                          branches: [[name: '*/main']], 
                          doGenerateSubmoduleConfigurations: false, 
                          extensions: [[$class: 'CloneOption', 
                                        noTags: false, 
                                        shallow: true, 
                                        timeout: 2]], 
                          submoduleCfg: [], 
                          userRemoteConfigs: [[credentialsId: 'git-credentials', 
                                              url: 'https://github.com/seyoon12/product_ci_eks.git']]])
            }
        }
        stage('Build and Push Image') {
            steps {
                container('kaniko') {
                    sh '''
                        /kaniko/executor \
                        --dockerfile=https://github.com/seyoon12/product_ci_eks/Dockerfile \
                        --context=./product_ci_eks \
                        --destination=${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
                    '''
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
