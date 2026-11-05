up:
	kind create cluster --config kind-config.yaml
	kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

deploy:
	kubectl apply -f k8s/

down:
	kind delete cluster --name sre-lab