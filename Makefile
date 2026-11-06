up:
	kind create cluster --config kind-config.yaml
	kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

deploy:
	kubectl apply -f k8s/

down:
	kind delete cluster --name sre-lab

lint:
	helm lint helm/mi-api

template:
	helm template mi-api helm/mi-api -n mi-api

install-dev:
	helm upgrade --install mi-api helm/mi-api -n mi-api -f helm/mi-api/values-dev.yaml --atomic

install-prod:
	helm upgrade --install mi-api helm/mi-api -n mi-api -f helm/mi-api/values-prod.yaml --atomic