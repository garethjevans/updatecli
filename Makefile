
GOVERSION=$(shell go version)
export GOVERSION

DOCKER_IMAGE=olblak/updatecli
DOCKER_TAG=$(shell git describe --tags)
DOCKER_BUILDKIT=1
export DOCKER_BUILDKIT

local_bin=./dist/updatecli_$(shell go env GOHOSTOS)_$(shell go env GOHOSTARCH)/updatecli

.PHONY: build
build: ## Build updatecli as a "dirty snapshot" (no tag, no release, but all OS/arch combinations)
	echo $(VERSION)
	goreleaser build --snapshot --rm-dist

.PHONY: build.all
build.all: ## Build updatecli for "release" (tag or release and all OS/arch combinations)
	goreleaser --rm-dist --skip-publish

.PHONY: diff
diff: ## Run the "diff" updatecli's subcommand for smoke test
	"$(local_bin)" diff --config ./updateCli.d

.PHONY: show
show: ## Run the "show" updatecli's subcommand for smoke test
	"$(local_bin)" show --config ./updateCli.d

.PHONY: apply
apply: ## Run the "apply" updatecli's subcommand for smoke test
	"$(local_bin)" apply --config ./updateCli.d

.PHONY: version
version: ## Run the "version" updatecli's subcommand for smoke test
	"$(local_bin)" version

.PHONY: docker.build
docker.build: ## Build the updatecli's Docker image
	docker build \
		-t "$(DOCKER_IMAGE):$(DOCKER_TAG)" \
		-t "$(DOCKER_IMAGE):latest" \
		-t "ghcr.io/$(DOCKER_IMAGE):$(DOCKER_TAG)" \
		-t "ghcr.io/$(DOCKER_IMAGE):latest" \
		-f Dockerfile \
		.

.PHONY: docker.run
docker.run: docker.build ## Execute the updatecli's Docker image
	docker run -i -t --rm --name updatecli $(DOCKER_IMAGE):$(DOCKER_TAG) --help

.PHONY: docker.test
docker.test: docker.build ## Smoke Test the updatecli's Docker image
	docker run -i -t \
		-v $$PWD/updateCli.d:/home/updatecli/updateCli.d:ro \
		"$(DOCKER_IMAGE):$(DOCKER_TAG)" --config /home/updatecli/updateCli.d/pluginsite-api.yaml

.PHONY: docker.push
docker.push: docker.build ## Push the updatecli's Docker image to remote registry
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest
	docker push ghcr.io/$(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push ghcr.io/$(DOCKER_IMAGE):latest

.PHONY: display
display: ## Prints the current DOCKER_TAG
	echo $(DOCKER_TAG)

.PHONY: test
test: ## Execute the Golang's tests for updatecli
	go test ./...

.PHONY: lint
lint: ## Execute the Golang's linters on updatecli's source code
	golangci-lint run

.PHONY: help
help: ## Show this Makefile's help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
