helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install klm-local-nginx ingress-nginx/ingress-nginx \
--namespace ingress-nginx \
--create-namespace \
--set controller.service.type=LoadBalancer \
--set controller.service.externalIPs[0]=172.27.0.2 \
--set controller.extraArgs.enable-ssl-passthrough=true
