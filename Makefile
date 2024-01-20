APP_NAME=codeflix-web
APP_PORT=8080
APP_VERSION=$(shell jq -r '.version' package.json)
APP_HOSTNAME=0.0.0.0

DOCKER_USER=jhonatanrs

install-deps:
	@echo "Installing pre-commit tools"
	sudo apt update
	sudo apt install -y jq
	pip3 install pre-commit
	@echo If "(pre-commit install)" fails try to restar your terminal and run it manually
	pre-commit install

lint-all:
	yarn lint && yarn pretty

run-dev:
	@echo "Installing deps..."
	yarn
	@echo "Starting development server..."
	@export PORT=$(APP_PORT) \
	export HOSTNAME=$(APP_HOSTNAME) \
	export VERSION=$(APP_VERSION) \
	&& yarn dev

build-image:
	yarn
	docker build \
	-t $(DOCKER_USER)/$(APP_NAME):$(APP_VERSION) \
	--tag $(DOCKER_USER)/$(APP_NAME):latest .