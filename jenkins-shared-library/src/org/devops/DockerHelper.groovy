package org.devops

class DockerHelper implements Serializable {
    private def script
    private String region
    private String ecrUrl

    DockerHelper(def script, String region, String ecrUrl) {
        this.script = script
        this.region = region
        this.ecrUrl = ecrUrl
    }

    def buildImage(String name, String tag) {
        script.sh "docker build -t ${name}:${tag} ."
        script.echo "Built image: ${name}:${tag}"
    }

    def pushImage(String name, String tag) {
        script.sh """
            aws ecr get-login-password --region ${region} | \
              docker login --username AWS --password-stdin ${ecrUrl}
            docker tag ${name}:${tag} ${ecrUrl}/${name}:${tag}
            docker push ${ecrUrl}/${name}:${tag}
        """
        script.echo "Pushed: ${ecrUrl}/${name}:${tag}"
    }

    def tagImage(String name, String oldTag, String newTag) {
        script.sh "docker tag ${name}:${oldTag} ${name}:${newTag}"
    }
}