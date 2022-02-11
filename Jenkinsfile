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
            steps {
                script {
                    sh 'docker build -t ${IMAGE_NAME} .'

                }
            }
        }
        stage ('Verification image') {
            steps {
                script {
                    sh '''
                        docker run -d -p 8081:8080 --name ${CONTAINTER_NAME} ${IMAGE_NAME}
                        curl http://localhost:8081 
                    '''
                }
            }   
        }
        stage ('Push image') {
            environment {
                PASSWORD=credentials('dockerhub_password')
            }
            steps {
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
            steps {
                withCredentials([sshUserPrivate(credentialsId: "credential_ec2", keyFileVariable: 'keyfile', username: 'sshuser')])
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE')
                script {
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${STAGING} -C \'docker stop ${CONTAINTER_NAME} || true\'
                        ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${STAGING} -C \'docker rm ${CONTAINTER_NAME} || true\'                        
                        ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${STAGING} -C \'docker run -d -p 80:8080 --name ${CONTAINTER_NAME} ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}\'
                        ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${STAGING} -C \'curl http://localhost:80\'
                    '''
                }
            }
        }
        stage ('Deploy prod') {
            steps {
                withCredentials([sshUserPrivate(credentialsId: "credential_ec2", keyFileVariable: 'keyfile', username: 'sshuser')])
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE')
                script {
                    timeout(time: 15, unit: "MINUTES") {
                        input message: 'Do you want to approve the deploy in production?', ok: 'Yes'
                    }
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${PRODUCTION} -C \'docker stop ${CONTAINTER_NAME} || true\'
                        ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${PRODUCTION} -C \'docker rm ${CONTAINTER_NAME} || true\'                        
                        ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${PRODUCTION} -C \'docker run -d -p 80:8080 --name ${CONTAINTER_NAME} ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}\'
                        ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${PRODUCTION} -C \'curl http://localhost:80\'
                    '''
                }
            }
        }
    }
}