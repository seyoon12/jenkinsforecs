pipeline {
    agent any
    environment {
        // 환경 변수 설정
        ECR_REGISTRY = "535597585675.dkr.ecr.ap-northeast-2.amazonaws.com"
        IMAGE_NAME = "product_ci"
        TAG = "latest"
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
                    // Kaniko Pod 정의
                    def kanikoPod = """
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
"""

                    // Kaniko Pod YAML을 파일로 저장
                    writeFile file: 'kaniko-pod.yaml', text: kanikoPod

                    // kubectl을 사용하여 Kaniko Pod 생성
                    sh "kubectl create -f kaniko-pod.yaml"
                    // 생성된 Pod 이름을 가져옴
                    def podName = sh(script: "kubectl get pods -l job-name=kaniko-job -o jsonpath='{.items[0].metadata.name}'", returnStdout: true).trim()
                    // Kaniko Pod이 성공적으로 완료될 때까지 대기
                    sh "kubectl wait --for=condition=complete --timeout=600s pod ${podName} -n product-ci"
                    // 로그를 확인할 수 있도록 Kaniko Pod의 로그를 출력
                    sh "kubectl logs ${podName} -n product-ci"
                }
            }
        }
    }
}
