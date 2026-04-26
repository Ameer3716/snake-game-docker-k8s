// Usage in Jenkinsfile: blueGreenDeploy(ecrImage: '...', albArn: '...', region: '...')
def call(Map params) {
    ['ecrImage', 'albArn', 'region'].each { key ->
        if (!params[key]) error("blueGreenDeploy: '${key}' is required")
    }
    // Logic in Task 7 section
    echo "Blue-Green deploy: ${params.ecrImage}"
}