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
                checkout scm // 소스 코드 체크아웃
            }
        }
        stage('Build and push Docker image with Kaniko') {
            steps {
                script {
                    // Kubernetes 플러그인을 사용하여 Kaniko Pod 실행
                    podTemplate(yaml: '''
apiVersion: v1
kind: Pod
metadata:
  name: kaniko
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
''') {
                        // Pod가 완료될 때까지 기다립니다.
                        container('kaniko') {
                        }
                    }
                }
            }
        }
    }
    post {
        always {
          script {
            // 파이프라인이 끝나면 Kaniko Pod를 정리합니다.
                if (currentBuild.result != 'SUCCESS') {
                    echo 'Cleaning up Kaniko pod...'
                    kubernetesDeletePod(name: 'kaniko', namespace: 'product-ci')
        }
    }
}
}
}
