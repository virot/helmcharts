# SearXNG Helm Chart

This Helm chart deploys [SearXNG](https://docs.searxng.org/), a privacy-respecting metasearch engine, on Kubernetes.

## Features

- Deploy SearXNG with persistent storage for configuration and cache
- Optional Redis/Valkey deployment for improved performance
- Configurable ingress with TLS support
- Extensive configuration options for SearXNG settings
- Security contexts following best practices

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for persistent volumes)

## Installing the Chart

To install the chart with the release name `my-searxng`:

```bash
helm install my-searxng ./searxng
```

The command deploys SearXNG on the Kubernetes cluster with default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-searxng` deployment:

```bash
helm uninstall my-searxng
```

## Parameters

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of SearXNG replicas | `1` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full release name | `""` |

### Image Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | SearXNG image repository | `docker.io/searxng/searxng` |
| `image.tag` | SearXNG image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `8080` |

### Ingress Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### Persistence Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.storageClassName` | Storage class for all PVCs | `""` |
| `persistence.config.enabled` | Enable config persistence | `true` |
| `persistence.config.size` | Config PVC size | `1Gi` |
| `persistence.config.accessModes` | Config PVC access modes | `[ReadWriteOnce]` |
| `persistence.cache.enabled` | Enable cache persistence | `true` |
| `persistence.cache.size` | Cache PVC size | `1Gi` |
| `persistence.cache.accessModes` | Cache PVC access modes | `[ReadWriteOnce]` |

### SearXNG Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `env.SEARXNG_BASE_URL` | Base URL for SearXNG | `https://searxng.local/` |
| `env.SEARXNG_INSTANCE_NAME` | Instance name | `SearXNG` |
| `searxng.general.debug` | Enable debug mode | `false` |
| `searxng.search.safe_search` | Safe search level (0-2) | `0` |
| `searxng.search.autocomplete` | Autocomplete provider | `google` |
| `searxng.ui.default_theme` | Default UI theme | `simple` |

For complete SearXNG configuration options, see the [values.yaml](values.yaml) file and the [SearXNG documentation](https://docs.searxng.org/admin/settings/index.html).

### Redis Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.enabled` | Deploy Redis alongside SearXNG | `false` |
| `redis.image.repository` | Redis image repository | `docker.io/valkey/valkey` |
| `redis.image.tag` | Redis image tag | `8-alpine` |
| `redis.persistence.enabled` | Enable Redis persistence | `true` |
| `redis.persistence.size` | Redis PVC size | `1Gi` |

### Resource Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `256Mi` |

## Example Configurations

### Basic Installation with Ingress

```yaml
# values-basic.yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: search.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: searxng-tls
      hosts:
        - search.example.com

env:
  SEARXNG_BASE_URL: "https://search.example.com/"
```

Install with:
```bash
helm install my-searxng ./searxng -f values-basic.yaml
```

### With Redis for Better Performance

```yaml
# values-redis.yaml
redis:
  enabled: true
  persistence:
    enabled: true
    size: 2Gi

searxng:
  general:
    instance_name: "My Private Search"
```

### Custom SearXNG Settings

```yaml
# values-custom.yaml
searxng:
  general:
    debug: false
    instance_name: "Private Search Engine"
    contact_url: "mailto:admin@example.com"
  
  search:
    safe_search: 1
    autocomplete: "duckduckgo"
    default_lang: "en"
  
  ui:
    default_theme: "simple"
    infinite_scroll: true
    center_alignment: true
```

## Persistent Volumes

This chart creates two Persistent Volume Claims by default:

1. **Config PVC** (`/etc/searxng`): Stores SearXNG configuration files
2. **Cache PVC** (`/var/cache/searxng`): Stores persistent cache data (e.g., favicon cache)

To use a specific storage class:

```yaml
persistence:
  storageClassName: "fast-ssd"
```

## Security

This chart follows Kubernetes security best practices:

- Non-root user (UID/GID 977)
- Read-only root filesystem where possible
- Drops all Linux capabilities
- Uses seccomp profile

## Upgrading

To upgrade the chart:

```bash
helm upgrade my-searxng ./searxng
```

## Troubleshooting

### SearXNG not starting

1. Check pod logs:
   ```bash
   kubectl logs -f deployment/my-searxng-searxng
   ```

2. Verify PVCs are bound:
   ```bash
   kubectl get pvc
   ```

### Cannot access SearXNG

1. Check service and ingress:
   ```bash
   kubectl get svc,ingress
   ```

2. Verify ingress controller is working
3. Check DNS resolution for your hostname

## More Information

- [SearXNG Documentation](https://docs.searxng.org/)
- [SearXNG GitHub](https://github.com/searxng/searxng)
- [SearXNG Settings Reference](https://docs.searxng.org/admin/settings/index.html)

## License

This Helm chart is provided as-is. SearXNG is licensed under the GNU Affero General Public License.
