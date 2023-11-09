pipeline {
    agent any
    environment {
        // 환경 변수 설정
        ECR_REGISTRY = "535597585675.dkr.ecr.ap-northeast-2.amazonaws.com"
        IMAGE_NAME = "product_ci"
    }
    stages {
      stage('Prepare') {
            steps {
                script {
                    // Jenkins 빌드 번호를 사용하여 메이저 버전 생성
                    def majorVersion = "${BUILD_NUMBER}"
                    // 빌드 번호에 1.0, 2.0 같은 형식을 적용
                    def semanticVersion = "${majorVersion}.0"
                    
                    // 이 버전을 환경 변수로 등록하여 다른 스테이지에서 사용할 수 있도록 합니다.
                    env.TAG = semanticVersion
                }
            }
        }
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
        stage('Get Kubernetes Secret') {
            steps {
                script {
                    // Kubernetes 시크릿 값을 가져와서 환경 변수로 설정
                    def GIT_USER = sh (
                        script: "kubectl get secret argocd -n product-ci -o jsonpath='{.data.GIT_USER}' | base64 --decode",
                        returnStdout: true
                    ).trim()
                    def GIT_PASSWORD = sh (
                        script: "kubectl get secret argocd -n product-ci -o jsonpath='{.data.GIT_PASSWORD}' | base64 --decode",
                        returnStdout: true
                    ).trim()
                    
                    // 가져온 값은 환경 변수로 설정
                    env.GIT_USER = GIT_USER
                    env.GIT_PASSWORD = GIT_PASSWORD
                }
            }
        }
        stage('Set Git User Info') {
    steps {
        sh "git config --global user.email 'wntpqhd1326@gmail.com'"
        sh "git config --global user.name 'seyoon12'"
    }
}

        stage('Deploy argocd') {
    steps {
        script {
            def repoDirectory = 'product_argocd'
            sh "rm -rf ${repoDirectory}"
            
            // 다른 리포지토리를 클론합니다.
            sh "git clone https://${GIT_USER}:${GIT_PASSWORD}@github.com/seyoon12/product_argocd.git ${repoDirectory}"
            
            // 클론한 리포지토리 디렉토리로 이동합니다.
            dir(repoDirectory) {
                // 원격 저장소에서 최신 변경사항을 가져옵니다.
                sh "git checkout main"
                sh "git pull origin main"
                // deployment.yml 파일에서 이미지 태그를 새로운 태그로 업데이트합니다.
                sh """
                    sed -i "s|${ECR_REGISTRY}/${IMAGE_NAME}:.*|${ECR_REGISTRY}/${IMAGE_NAME}:${TAG}|g" deployment.yml
                    git add deployment.yml
                    git commit -m "Update image tag to ${env.TAG}"
                    git push origin HEAD:master
                """
            }
        }
    }
}
}
}
