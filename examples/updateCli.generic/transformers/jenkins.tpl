source:
  name: "Get latest jenkins weekly version"
  kind: jenkins
  transformers:
    - addPrefix: "alpha-"
    - addSuffix: "-jdk11"
    - trimSuffix: "-jdk11"
    - addSuffix: "-jdk11"
    - replacer:
        from: "-jdk11"
        to: "-jdk15"
    - replacers:
        - from: "-jdk15"
          to: "-jdk17"
  spec:
    release: weekly
targets:
  targetID:
    name: "Update file file"
    kind: file
    spec:
      file: TODO
