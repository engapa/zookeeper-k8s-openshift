.DEFAULT_GOAL := help

DOCKER_ORG           ?= engapa
DOCKER_IMAGE         ?= zookeeper

ZK_VERSION           ?= 3.5.5

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
	@docker run -d --rm --name zk $(DOCKER_ORG)/$(DOCKER_IMAGE):$(ZK_VERSION)

.PHONY: docker-test
docker-test: docker-run ## Test for docker container
	@until [ "$$(docker ps --filter 'name=zk' --filter 'health=healthy' --format '{{.Names}}')" == "zk" ]; do \
	   sleep 10; \
	   (docker ps --filter 'name=zk' --format '{{.Names}}' | grep zk > /dev/null 2>&1) || exit $$?; \
	   echo "Checking healthy status of zookeeper ..."; \
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

.PHONY: minikube-test-persistent
minikube-test-persistent: ## Launch tests on minikube with persistent volumes
	@k8s/main.sh test-persistent

.PHONY: minikube-clean
minikube-clean: ## Remove kubernetes resources
	@k8s/main.sh clean-all

.PHONY: minikube-delete
minikube-delete: ## Remove minikube cluster
	@k8s/main.sh minikube-delete

.PHONY: oc-install
oc-install: ## Install oc tools
	@openshift/main.sh oc-install

.PHONY: oc-cluster-run
oc-cluster-run: ## Run a cluster through oc command
	@openshift/main.sh oc-cluster-run

.PHONY: oc-cluster-test
oc-cluster-test: ## Launch tests on our local openshift cluster
	# Test with 3 replicas
	@openshift/main.sh test 3

.PHONY: oc-clean-resources
oc-clean-resources: ## Clean zk resources
	@openshift/main.sh clean-resources

.PHONY: oc-cluster-test-persistent
oc-cluster-test-persistent: ## Launch tests on our local openshift cluster with persistence
	# Test with 3 replicas
	@openshift/main.sh test-persistent 3

.PHONY: oc-cluster-clean
oc-cluster-clean: ## Remove openshift cluster
	@openshift/main.sh oc-cluster-clean

## TODO: helm, ksonnet for deploy on kubernetes