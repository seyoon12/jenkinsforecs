node {
    stage('Clone repository') {
        checkout scm // Git 리포지토리에서 코드를 체크아웃합니다.
    }

    stage('Build image') {
        // Docker 이미지를 빌드하고 ECR 저장소 이름을 태그로 사용합니다.
        app = docker.build("535597585675.dkr.ecr.ap-northeast-2.amazonaws.com/cicd")
    }

    stage('Push image') {
        // 기존 Docker 인증 정보를 삭제합니다.
        sh 'rm ~/.dockercfg || true'
        sh 'rm ~/.docker/config.json || true'
        
        // ECR로 로그인하고 이미지를 푸시합니다. 'jenkinsaws'는 Jenkins 내에 설정된 AWS 자격증명 ID입니다.
        docker.withRegistry('https://535597585675.dkr.ecr.ap-northeast-2.amazonaws.com', 'ecr:ap-northeast-2:jenkinsaws') {
            app.push("${env.BUILD_NUMBER}") // 빌드 번호를 태그로 사용하여 이미지를 푸시합니다.
            app.push("latest") // 'latest' 태그를 사용하여 이미지를 푸시합니다.
        }
    }
}
