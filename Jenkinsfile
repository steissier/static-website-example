pipeline{
    environment{
        IMAGE_NAME = "img-webapp"
        IMAGE_TAG = "latest"
        USERNAME = "26021973"
        CONTAINTER_NAME = "webapp"
        STAGING = "52.21.170.76"
        PRODUCTION = "18.205.185.188"
    }
    agent any
    
    stages {
        stage ('Build du conteneur') {
            step {
                script {
                    sh 'docker build -t ${IMAGE_NAME} .'

                }
            }
        }
        stage ('Verification image') {
            step {
                script {
                    sh '''
                        docker run -d -p 80:8080 --name ${CONTAINTER_NAME} ${IMAGE_NAME}
                        curl http://localhost:80 
                    '''
                }
            }   
        }
        stage ('Push image') {
            environment {
                PASSWORD=credentials('dockerhub_password')
            }
            step {
                script {
                    sh '''
                        docker stop ${CONTAINTER_NAME}
                        docker rm ${CONTAINTER_NAME}
                        docker tag ${IMAGE_NAME} ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker login -u ${USERNAME} -p ${PASSWORD}
                        docker push ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker rmi ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    '''

                }
            }
        }
        stage ('Deploy staging') {
            environment {
                PASSWORD=credentials('credential_ec2')
            }
            step {
                script {
                    sh '''
                        ssh add ${PASSWORD}
                        ssh -i ${PASSWORD} -y ubuntu@${STAGING}
                        docker stop ${CONTAINTER_NAME} || true
                        docker rm ${CONTAINTER_NAME} || true
                        docker run -d -p 80:8080 --name ${CONTAINTER_NAME} ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        curl http://localhost:80
                    '''
                }
            }
        }
        stage ('Deploy prod') {
            environment {
                PASSWORD=credentials('credential_ec2')
            }
            step {
                script {
                    timeout(time: 15, unit: "MINUTES") {
                        input message: 'Do you want to approve the deploy in production?', ok: 'Yes'
                    }
                    sh '''
                        ssh -i ${PASSWORD} -y ubuntu@${PRODUCTION}
                        docker stop ${CONTAINTER_NAME} || true
                        docker rm ${CONTAINTER_NAME} || true
                        docker run -d -p 80:8080 --name ${CONTAINTER_NAME} ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        curl http://localhost:80
                    '''
                }
            }
        }
    }
}