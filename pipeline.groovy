def label = "jenkins-dind-slave-${UUID.randomUUID().toString()}"
podTemplate(label: label, containers: [
    containerTemplate(name: 'jenkins-dind-slave', image: 'jonpraw/jenkins-dind-slave', ttyEnabled: true, privileged: true ,args: '${computer.jnlpmac} ${computer.name}')
]) {
    node(label) {
        stage('Check docker version') {
            sh 'docker version'
        }
    }
}