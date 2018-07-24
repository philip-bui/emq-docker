DOCKER:=philipbui/emq-docker
CLUSTER:=emqtt
FILE_NAME:=emqtt.yaml
SECRET_FILE_NAME:=secret.yaml
NAME:=emqtt

help: ## Display this help screen
	grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'	

build: ## Build Docker Container
	docker build -t ${DOCKER} .

test: build ## Test Build
	docker run -d --name ${NAME} -p 18083:18083 ${DOCKER}
	sleep 10
	curl -f 127.0.0.1:18083
	make stop

run: ## Run Application
	docker run --rm -ti --name ${NAME} -p 18083:18083 -p 1883:1883 ${DOCKER}

stop: ## Stop Application (if in Daemon)
	docker stop ${NAME}
	docker rm ${NAME}

cluster: ## Create Google Cloud Cluster and Authenticate
	gcloud container clusters create ${CLUSTER}
	gcloud container clusters get-credentials ${CLUSTER}

secret: ## Create Secret
	kubectl create -f ${SECRET_FILE_NAME}

deploy: ## Deploy EMQTT to Kubernetes
	kubectl apply -f ${FILE_NAME}

delete: ## Delete EMQTT in Kubernetes
	kubectl delete -f ${FILE_NAME}
