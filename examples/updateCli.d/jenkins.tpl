source:
  kind: maven
  name: "Get latest jenkins weekly version from maven repository"
  postfix: "-jdk11"
  spec:
    owner: "maven"
    url: "repo.jenkins-ci.org"
    repository: "releases"
    groupID: "org.jenkins-ci.main"
    artifactID: "jenkins-war"
conditions:
  docker:
    name: "Is Docker Image Published on Registry?"
    kind: dockerImage
    spec:
      image: "jenkins/jenkins"
targets:
  imageTag:
    name: "Update Jenkins docker image tag"
    kind: yaml
    #prefix: "test-"
    #postfix: "-jdk13"
    spec:
      file: "charts/jenkins/values.yaml"
      key: "jenkins.controller.imageTag"
    scm:
      github:
        user: "{{ .github.user }}"
        email: "{{ .github.email }}"
        owner: "{{ .github.owner }}"
        repository: "{{ .github.repository }}"
        token: "{{ requiredEnv .github.token }}"
        username: "{{ .github.username }}"
        branch: "{{ .github.branch }}"
