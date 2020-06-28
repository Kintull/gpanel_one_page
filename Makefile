.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build-dev: ## Build development Docker image
	docker build --build-arg GPANEL_HOST=localhost \
		--build-arg GPANEL_INTERNAL_PORT=4004 \
		--build-arg GPANEL_EXTERNAL_PORT=443 \
		--build-arg GPANEL_SSL_CERT_PATH=priv/cert/selfsigned.pem \
		--build-arg GPANEL_SSL_KEY_PATH=priv/cert/selfsigned_key.pem \
		--build-arg GPANEL_SECRET_KEY_BASE=N1uVAABEQ5AVnOjtUvjt1wVrEQ+e4GNjhvU5RQmGaiC8KT6baGYpG02kYD4apLmT \
		-t kintull/gpanel_one_page:latest .

build-prod: # Build production Docker image
	echo $GPANEL_HOST
	docker build --build-arg GPANEL_HOST=${GPANEL_HOST} \
		--build-arg GPANEL_INTERNAL_PORT=${GPANEL_INTERNAL_PORT} \
		--build-arg GPANEL_EXTERNAL_PORT=${GPANEL_EXTERNAL_PORT} \
		--build-arg GPANEL_SSL_CERT_PATH=${GPANEL_SSL_CERT_PATH} \
		--build-arg GPANEL_SSL_KEY_PATH=${GPANEL_SSL_KEY_PATH} \
		--build-arg GPANEL_SECRET_KEY_BASE=${GPANEL_SECRET_KEY_BASE} \
		-t kintull/gpanel_one_page:latest .

run: ## Run the app in Docker
	docker-compose up -d