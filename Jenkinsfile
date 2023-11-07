pipeline {
    agent any // Jenkins 마스터 노드에서 실행
    environment {
        // 환경 변수 설정
        ECR_REGISTRY = "535597585675.dkr.ecr.ap-northeast-2.amazonaws.com"
        IMAGE_NAME = "product_ci"
        TAG = "latest" // 또는 파라미터나 버전으로부터 동적으로 생성
    }
    stages {
        stage('Checkout code') {
            steps {
                checkout scm
            }
        }
        stage('Build and push Docker image with Kaniko') {
            steps {
                script {
                    // YAML 파일을 사용하여 Kaniko Pod 생성
                    sh 'kubectl apply -f kanikoo.yml -n product-ci'
                    // Pod가 완료될 때까지 기다림
                    sh "kubectl wait --for=condition=complete --namespace=product-ci pod/kaniko"
                    // Pod 로그를 출력
                    sh "kubectl logs --namespace=product-ci kaniko"
                    // 사용이 끝난 후 Pod 제거
                    sh "kubectl delete pod kaniko --namespace=product-ci"
                }
            }
        }
    }
}
