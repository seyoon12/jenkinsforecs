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
//kaniko는 빌드가 끝난 후 스스로 삭제되기 때문에 삭제하는 문구를 적지 않았다. 
 
                }
            }
        }
    }
}
