.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the Docker image
	docker build --build-arg GPANEL_HOST=localhost \
     --build-arg GPANEL_INTERNAL_PORT=4004 \
     --build-arg GPANEL_EXTERNAL_PORT=443 \
     --build-arg GPANEL_SSL_CERT_PATH=priv/cert/selfsigned.pem \
     --build-arg GPANEL_SSL_KEY_PATH=priv/cert/selfsigned_key.pem \
     -t kintull/gpanel_one_page:latest .

run: ## Run the app in Docker
	docker-compose up -d