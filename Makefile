.DEFAULT_GOAL := help

DOCKER_ORG           ?= engapa
DOCKER_IMAGE         ?= zookeeper

ZK_VERSION           ?= 3.4.13

KUBE_VERSION         ?= v1.11.3
MINIKUBE_VERSION     ?= v0.30.0

OC_VERSION           ?= v3.11.0
MINISHIFT_VERSION    ?= v1.26.1

.PHONY: help
help: ## Show this help
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## Clean docker containers and images
	@docker rm -f $$(docker ps -a -f "ancestor=$(DOCKER_ORG)/$(DOCKER_IMAGE):$(ZK_VERSION)" --format '{{.Names}}') > /dev/null 2>&1 || true
	@docker rmi -f $(DOCKER_ORG)/$(DOCKER_IMAGE):$(ZK_VERSION) > /dev/null 2>&1 || true

.PHONY: docker-build
docker-build: ## Build the docker image
	@docker build --no-cache \
	  -t $(DOCKER_ORG)/$(DOCKER_IMAGE):$(ZK_VERSION) .

.PHONY: docker-run
docker-run: ## Create a docker container
	@docker run -d --name zk $(DOCKER_ORG)/$(DOCKER_IMAGE):$(ZK_VERSION)

.PHONY: docker-test
docker-test: docker-run ## Test for docker container
	@until [ "$$(docker ps --filter 'name=zk' --filter 'health=healthy' --format '{{.Names}}')" == "zk" ]; do \
	   echo "Checking healthy status of zookeeper ..."; \
	   sleep 20; \
	done

.PHONY: docker-push
docker-push: ## Publish docker images
	@docker push $(DOCKER_ORG)/$(DOCKER_IMAGE):$(ZK_VERSION)

.PHONY: minikube-install
minikube-install: ## Install minikube and kubectl
	@k8s/main.sh minikube-install
	@k8s/main.sh kubectl-install

.PHONY: minikube-run
minikube-run: ## Run minikube
	@k8s/main.sh minikube-run

.PHONY: minikube-test
minikube-test: ## Launch tests on minikube
	@k8s/main.sh test

.PHONY: minikube-clean
minikube-clean: ## Remove minikube
	@k8s/main.sh clean

.PHONY: oc-install
oc-install: ## Install oc tools
	@openshift/main.sh oc-install

.PHONY: oc-cluster-run
oc-cluster-run: ## Run a cluster through oc command
	@openshift/main.sh oc-cluster-run

.PHONY: oc-cluster-test
oc-cluster-test: ## Launch tests on our local openshift cluster
	@openshift/main.sh test

.PHONY: oc-cluster-clean
oc-cluster-clean: ## Remove openshift cluster
	@openshift/main.sh oc-cluster-clean

## TODO: helm, ksonnet for deploy on kubernetes