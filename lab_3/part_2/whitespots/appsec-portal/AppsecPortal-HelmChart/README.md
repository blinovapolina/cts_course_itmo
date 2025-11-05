# AppSec Portal Helm Chart

## System Requirements

- Very minimum: 4 GB RAM and 2 CPU cores
- Recommended (for 500-700 assets): 16 GB RAM and 4 CPU cores
- Sufficient disk space for installation and data storage
- Network access for external users

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support (if using persistent storage)
- ⚠️ Note: incompatible with Amazon Aurora database

## Installation Steps

0. Make sure everything is ok and create a namespace


1. Add the Helm repository:

```shell
helm repo add portal https://gitlab.com/api/v4/projects/37960926/packages/helm/stable
helm repo update
```

2. Configure required values:

### Release Version
```shell
global.image.tag=release_v25.01.1
```

### Jira Webhook (if needed)
```shell
webhook.ingress.path="/api/v1/jira-helper/jira-event/<your-webhook>/"
```
Replace `<your-webhook>` with your unique identifier (e.g., e2b7e8be-1c77-4969-9105-58e91bd311cc)

### Required ConfigMap Values
```yaml
configs.configMap:
   cookies_secure: "True"  # Set to True if using HTTPS
   database.host: "postgres"
   debug: "True"
   domain: "http://localhost"
   gunicorn_workers: "4"  # Recommended for 1M findings
   gunicorn_threads: "4"
   importer_gunicorn_workers: "1"
   importer_gunicorn_threads: "1"
```

### Required Secret Values
```yaml
configs.secret:
   jwt_private_key: "<your-key>"  # RSA private key
   jwt_public_key: "<your-key>"   # RSA public key
   secret_key: "<your-key>"       # Django secret key
```

3. Example install with default PostgreSQL and RabbitMQ:
```shell
helm upgrade --install portal portal/portal \
   --set postgresql.enabled=true \
   --set ingress.enabled=true \
   --set rabbitmq.enabled=true \
   --set rabbitmq.auth.username="admin" \
   --set rabbitmq.auth.password="admin" \
   --set ingress.annotations."nginx\.ingress\.kubernetes\.io\/scheme"=internet-facing \
   --set ingress.annotations."nginx\.ingress\.kubernetes\.io\/proxy\-body\-size"=4g \
   --set ingress.annotations."nginx\.ingress\.kubernetes\.io\/target\-type"=ip \
   --set ingress.ingressClassName=nginx \
   --set ingress.host=localhost \
   --set configs.configMap.cookies_secure=false \
   -n whitespots-portal --create-namespace
```

3.1 Example install with external PostgreSQL and external RabbitMQ:
```shell
helm upgrade --install portal portal/portal \
   --set postgresql.enabled=false \
   --set rabbitmq.enabled=false \
   --set externalRabbitmq.enabled=true \
   --set externalRabbitmq.scheme="amqps" \
   --set externalRabbitmq.port="5671" \
   --set externalRabbitmq.username="myuser" \
   --set externalRabbitmq.vhost="vhost" \
   --set externalRabbitmq.password="password" \
   --set externalRabbitmq.host="rabbit.cloudprovider.com" \
   --set externalPostgresql.enabled=true \
   --set externalPostgresql.host="postgres.cloudprovider.com" \
   --set externalPostgresql.port="5432" \
   --set externalPostgresql.database="postgres" \
   --set externalPostgresql.username="postgres" \
   --set externalPostgresql.password="postgres" \
   --set ingress.enabled=true \
   --set ingress.annotations."nginx\.ingress\.kubernetes\.io\/scheme"=internet-facing \
   --set ingress.annotations."nginx\.ingress\.kubernetes\.io\/proxy\-body\-size"=4g \
   --set ingress.annotations."nginx\.ingress\.kubernetes\.io\/target\-type"=ip \
   --set ingress.ingressClassName=nginx \
   --set ingress.host=localhost \
   --set configs.configMap.cookies_secure=false \
   -n whitespots-portal --create-namespace
```

Just in case if you don't have ingress:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace
```



4. Create admin user:
```shell
kubectl exec -it $(kubectl get pods -n whitespots-portal -l app.kubernetes.io/name=portal-portal -o jsonpath='{.items[0].metadata.name}') -n whitespots-portal -- python manage.py createsuperuser --username admin
```

How to manually run migrations:
```shell
kubectl exec -it $(kubectl get pods -n whitespots-portal -l app.kubernetes.io/name=portal-portal -o jsonpath='{.items[0].metadata.name}') -n whitespots-portal -- python manage.py migrate
```


## Post-Installation

1. Access the Django admin panel at `<your-domain>.com/admin`
2. Log in with the superuser credentials created earlier
3. Apply your AppSec Portal license
4. Create additional users and assign permissions as needed

## Troubleshooting Migrations

If migrations fail, you can:

1. Check migration logs:

```bash
kubectl logs -l app=<release-name>-migrations
```

2. Run migrations manually:

```bash
kubectl exec -it -n whitespots-portal <portal-pod-name> -- python manage.py migrate
```

## update

```bash
helm upgrade portal portal/portal \
  --namespace whitespots-portal \
  --version 25.5.1
```

## Support

If you encounter any issues during installation or usage, contact support at sales@whitespots.io.