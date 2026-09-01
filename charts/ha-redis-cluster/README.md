# ha-redis-cluster

A Helm chart for deploying a Redis HA cluster backed by [redis-ha](https://github.com/DandyDeveloper/charts/tree/master/charts/redis-ha) with HAProxy. Designed to run independently from any specific application — use it with Argo CD or any other workload that needs a highly-available Redis.

## TL;DR

```bash
helm repo add argo-helm https://argoproj.github.io/argo-helm
helm install my-redis argo-helm/ha-redis-cluster
```

## Introduction

This chart wraps the `redis-ha` subchart with opinionated defaults and an optional `redis-secret-init` Job that auto-generates a random Redis password and stores it in a Kubernetes Secret.

## Prerequisites

- Kubernetes 1.25+
- Helm 3.x

## Installing the Chart

```bash
helm install my-redis argo-helm/ha-redis-cluster \
  --namespace redis \
  --create-namespace
```

## Connecting Argo CD to this Cluster

After installing this chart, point the `argo-cd` Helm chart at the HAProxy service:

```bash
helm upgrade argo-cd argo-helm/argo-cd \
  --set redis-ha.enabled=false \
  --set externalRedis.host=my-redis-redis-ha-haproxy.<namespace>.svc.cluster.local \
  --set externalRedis.existingSecret=argocd-redis
```

> Replace `<namespace>` with the namespace where `ha-redis-cluster` is installed.

## Connecting Other Applications

The HAProxy service exposes Redis at port `6379` and automatically forwards connections to the current Redis master. Sentinel is available on port `26379`.

```
Host: <release-name>-redis-ha-haproxy.<namespace>.svc.cluster.local
Port: 6379
```

## Values

| Key | Description | Default |
|-----|-------------|---------|
| `redis-ha.image.repository` | Redis image repository | `ecr-public.aws.com/docker/library/redis` |
| `redis-ha.image.tag` | Redis image tag | `8.2.3-alpine` |
| `redis-ha.redis.masterGroupName` | Sentinel master group name | `argocd` |
| `redis-ha.haproxy.enabled` | Enable HAProxy | `true` |
| `redis-ha.haproxy.labels` | Labels for HAProxy pods | `{app.kubernetes.io/name: argocd-redis-ha-haproxy}` |
| `redis-ha.auth` | Enable Redis AUTH | `true` |
| `redis-ha.existingSecret` | Secret containing the Redis password | `argocd-redis` |
| `redis-ha.persistentVolume.enabled` | Enable persistence | `false` |
| `redis-ha.hardAntiAffinity` | Force Redis pods on separate nodes | `true` |
| `redisSecretInit.enabled` | Enable the password-generation Job | `true` |
| `redisSecretInit.image.repository` | Image for the secret-init Job (Argo CD image) | `quay.io/argoproj/argocd` |
| `redisSecretInit.image.tag` | Tag for the secret-init Job image | `""` (defaults to Chart appVersion) |

For the full list of `redis-ha` subchart values, see the [redis-ha chart documentation](https://github.com/DandyDeveloper/charts/blob/master/charts/redis-ha/values.yaml).

## Secret Initialization

By default, the chart deploys a one-time Helm hook Job (`redisSecretInit`) that runs `argocd admin redis-initial-password` to generate a random password and store it in the Secret named by `redis-ha.existingSecret` (default: `argocd-redis`).

To disable auto-generation and supply your own secret:

```yaml
redisSecretInit:
  enabled: false

redis-ha:
  existingSecret: my-redis-secret  # must contain key `redis-password`
```

## Uninstalling the Chart

```bash
helm uninstall my-redis
```

Note: the Redis password secret is **not** deleted automatically. Remove it manually if needed:

```bash
kubectl delete secret argocd-redis -n <namespace>
```
