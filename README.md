concourse-bitbucket-pullrequest-resource
========================================

A Concourse resource that you can use to get pullrequests

[aecepoglu/concourse-bitbucket-pr-resource on Docker Hub](https://hub.docker.com/r/aecepoglu/concourse-bitbucket-pr-resource/)

Source Configuration
-----------------------

* `url`: *REQUIRED* path to your bitbucket instance. For example: *http://192.168.2.200:7990*. *Port number should be defined in the url (even if it is a default like 80).*
* `project`: *REQUIRED* bitbucket project to retrieve PRs from
* `repo`: *REQUIRED* bitbucket repository to retrievee PRs from
* `username`: *REQUIRED* auth username for bitbucket
* `password`: *REQUIRED* auth password for bitbucket
* -
* `private_key`: *OPTIONAL* private key for git repository. Enter this if you want the resource to also clone the git repository of the latest commit of the branch
* `trusted_hosts`: *OPTIONAL* (use with `private_key`) Disables *StrictHostKeyChecking* for entered hosts. For example: `["my_bitbucket_instance"]`
* -
* `resolve_hostnames`: *OPTIONAL but REQUIRED with `private_key`* Values to put in /etc/hosts to help with hostname resolutions. For example: `{my_git_repo: 192.168.2.201}'.
* `state`: *OPTIONAL* state of PR. Can be *OPEN*, *DECLINED* or *MERGED*. Defaults to *OPEN*
* `filter_builds_only`: *OPTIONAL* If *true*, only returns pullrequests that have *SUCCESSFUL* builds. You can set its value to *my_build_key* to retrieve only the pullrequests that have *SUCCESSFUL* builds with key *my_build_key*. Useful when dealing with MERGED pullrequests *(for example if you want to terminate the build you took for a PR)*

Behaviour
---------

### Check

Retrieves a list of PRs.

### In

It will put the PR information (`pr_no`, `commit`, `updatedDate`) into various files to be used later in the pipeline.

    version.json #the PR info file
    version.yaml #the PR info file
    version.env  #the PR info file
    info/
      pr_no #contains pr_no value
    repo/ #the git repository (if private_key is entered)

### Out

Doesn't do anything

Sample
---------

    resource_types:
    - name: bitbucket-pr
      type: docker-image
      source:
        repository: aecepoglu/concourse-bitbucket-pr-resource

    resources:
    - name: new-pr
      type: bitbucket-pr
      source:
        username: MY_USERNAME
        password: MY_PASSWORD
        url: http://my_bitbucket_instance
        project: my_project
        repo: my_repo
        private_key: MY_PRIVATE_KEY_FOR_GIT

    jobs:
    - name: build-pr
      plan:
      - get: new-pr
      - task: "check"
        config:
          platform: "linux"
          source:
            repository: busybox
            tag: "1.25"
          inputs:
            - name: new-pr
          run:
            path: sh
            dir: new-pr/
            args:
              - -exc
              - |
                ls ./
		ls ./info
                cat version.json

And its output is:

    + ls ./
    info          version.env   version.json  version.yaml
    
    + ls ./info/
    pr_no
    
    + cat version.json
    {"commit": "96dbf4f", "pr_no": "960"}
