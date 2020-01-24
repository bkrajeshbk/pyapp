@Library('common') _
node('docker'){
    try{
        stage('Checkout and CCQ') {
            //checkout scm
            echo '\nChecking out.'
            checkout(
                scm: [$class: 'GitSCM',
                    branches: [[name: "master"]],
                    userRemoteConfigs: [
                        [
                            credentialsId: 'github-build-svc',
                            url: 'https://github.com/Rajeshkrishnamurthy5/pyapp.git'
                        ]
                    ]
                ]
            )
            echo 'Checked out the source code.. '
            withSonarQubeEnv {
                sh "sonar-scanner"
            }
            echo "\nSonarqube analysis completed."
            version = getVersion(readFile('VERSION.txt'))
            echo "build version=${version}"
        }

        stage('Build image') { // build and tag docker image
            steps {
                echo 'Starting to build docker image'
                script {
                    def dockerfile = 'Dockerfile'
                    def customImage = docker.build('192.168.43.37:8081/pyapp_project/pyapp-docker-image:latest', "-f ${dockerfile} .")
                }
            }
        }

        stage ('Push image to Artifactory') { // take that image and push to artifactory
            steps {
                rtDockerPush(
                    serverId: "jFrog-ar1",
                    image: "192.168.43.37:8081/pyapp_project/pyapp-docker-image:latest",
                    host: 'tcp://localhost:2375',
                    targetRepo: 'pyapp_project', // where to copy to (from pyapp_project)
                    // Attach custom properties to the published artifacts:
                    properties: 'project-name=pyapp_project;status=stable'
                )
            }
        }
    }
    catch(e){
        currentBuild.result = 'FAILED'
        throw e
    }
    finally{
        stage('Clean Up'){
            echo 'Initiating Cleaning up..'  
            deleteDir()
            echo 'Cleaned Up.'
        }
    }
}
	
def isMasterOrRelease(){
    return env.BRANCH_NAME == 'master' || env.BRANCH_NAME.endsWith('/master') || env.BRANCH_NAME.startsWith('release')
}

def getVersion(text) {
    def matcher = text =~ '^BUILD_VERSION = "(.*?)"'
    revision = ""
    if(!isMasterOrRelease()){
        branch_name = env.BRANCH_NAME
        /*if(branch_name.length() > 20){
            branch_name = branch_name.substring(0,19)
        }*/
        revision = ".${env.BUILD_NUMBER}-${branch_name}".toLowerCase()
    }
    matcher ? "${matcher[0][1]}${revision}" : null
}