IMAGE = enspirit/fakesmtp
SHELL=/bin/bash -o pipefail
DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},docker.io)

################################################################################
### Config variables
###

# Load them from an optional .env file
-include .env

# Specify which docker tag is to be used
VERSION := $(or ${VERSION},${VERSION},latest)
DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},docker.io)

TINY = ${VERSION}
MINOR = $(shell echo '${TINY}' | cut -f'1-2' -d'.')
MAJOR = $(shell echo '${MINOR}' | cut -f'1' -d'.')

$(info $(TINY) $(MINOR) $(MAJOR))

################################################################################
### Main docker rules
###

clean:
	rm -rf pkg/
	rm -rf Dockerfile.log Dockerfile.built Dockerfile.pushed

Dockerfile.built: Dockerfile $(shell git ls-files)
	docker build -t $(IMAGE) . | tee Dockerfile.log
	touch Dockerfile.built

image: Dockerfile.built

Dockerfile.version.pushed: Dockerfile.built
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):$(VERSION)
	docker push $(DOCKER_REGISTRY)/$(IMAGE):$(VERSION) | tee -a Dockerfile.log
	touch Dockerfile.version.pushed

Dockerfile.tags.pushed: Dockerfile.version.pushed
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):${MINOR}
	docker push $(DOCKER_REGISTRY)/$(IMAGE):$(MINOR) | tee -a Dockerfile.log
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):${MAJOR}
	docker push $(DOCKER_REGISTRY)/$(IMAGE):$(MAJOR) | tee -a Dockerfile.log
	touch Dockerfile.tags.pushed

push-image: Dockerfile.version.pushed
push-tags: Dockerfile.tags.pushed

################################################################################
### Main development rules
###

up: Dockerfile.built
	docker run -p 1080:1080 $(IMAGE)
