// Usage: buildAndPushImage(name: 'myapp', tag: 'abc123', ecrUrl: 'xxx.dkr.ecr...', region: 'us-east-1')
def call(Map params) {
    ['name', 'tag', 'ecrUrl', 'region'].each { key ->
        if (!params[key]) error("buildAndPushImage: '${key}' is required")
    }

    String name   = params.name
    String tag    = params.tag
    String ecrUrl = params.ecrUrl
    String region = params.region

    echo "Building Docker image ${name}:${tag}"
    sh "docker build -t ${name}:${tag} ."

    echo "Pushing to ECR: ${ecrUrl}/${name}:${tag}"
    sh """
        aws ecr get-login-password --region ${region} | \
          docker login --username AWS --password-stdin ${ecrUrl}
        docker tag ${name}:${tag} ${ecrUrl}/${name}:${tag}
        docker push ${ecrUrl}/${name}:${tag}
    """
}