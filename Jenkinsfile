pipeline {
    agent none // 'agent any' 대신 'agent none'을 사용하여 기본 에이전트를 사용하지 않습니다.

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
          name: github-secret
          key: token
    - name: GIT_USERNAME
      valueFrom:
        secretKeyRef:
          name: github-secret
          key: username
  restartPolicy: Never
''', name: 'kaniko-template') { // PodTemplate에 이름을 지정합니다.

                        // Kaniko 컨테이너 안에서 실행할 작업을 정의합니다.
                        container('kaniko') {
                            // 실제 빌드와 푸시를 실행하는 커맨드를 작성합니다.
                            // 예를 들어, Kaniko executor가 자동으로 빌드와 푸시를 수행합니다.
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            // 파이프라인이 끝나면 Kaniko Pod를 정리합니다.
            echo 'Cleaning up Kaniko pod...'
            // 템플릿 이름을 사용하여 Pod를 삭제합니다.
            kubernetesDeletePod(name: 'kaniko-template', namespace: 'product-ci')
        }
    }
}
