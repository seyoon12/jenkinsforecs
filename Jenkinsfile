pipeline {
    agent any // Jenkins 마스터 노드에서 실행하지 않고, 어느 에이전트에서든 실행 가능
    environment {
        // 환경 변수 설정
        ECR_REGISTRY = "535597585675.dkr.ecr.ap-northeast-2.amazonaws.com"
        IMAGE_NAME = "product_ci"
        TAG = "latest" // 또는 파라미터나 버전으로부터 동적으로 생성
    }
    stages {
        stage('Checkout code') {
            steps {
                checkout scm // 소스 코드 체크아웃
            }
        }
        stage('Build and push Docker image with Kaniko') {
            steps {
                script {
                    // 직접 Kaniko Pod를 생성하고, 이미지를 빌드 및 푸시
                    def kanikoPod = '''
apiVersion: v1
kind: Pod
metadata:
  generateName: kaniko-
  namespace: product-ci
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    args:
    - "--dockerfile=Dockerfile"
    - "--context=git://github.com/seyoon12/product_ci_eks"
    - "--destination=${ECR_REGISTRY}/${IMAGE_NAME}:${TAG}"
    env:
    - name: GIT_PASSWORD
      valueFrom:
        secretKeyRef:
          name: github
          key: token
    - name: GIT_USERNAME
      valueFrom:
        secretKeyRef:
          name: github
          key: username
  restartPolicy: Never
'''

                    // kubectl을 사용하여 Kaniko Pod 생성
                    sh "echo '${kanikoPod}' | kubectl apply -f -"
                    // Kaniko Pod이 성공적으로 완료될 때까지 대기
                    sh "kubectl wait --for=condition=complete --timeout=600s pod -l generateName=kaniko- -n product-ci"
                    // 로그를 확인할 수 있도록 Kaniko Pod의 로그를 출력
                    sh "kubectl logs --selector=generateName=kaniko- -n product-ci"
                }
            }
        }
    }
}
