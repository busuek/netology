# Домашнее задание к занятию «Kubernetes. Причины появления. Команда kubectl»

## Цель задания
Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине или на отдельной виртуальной машине MicroK8S.

## Задание 1. Установка MicroK8S
1. Установить MicroK8S на локальную машину или на удалённую виртуальную машину.
```
[vega@fedora ~]$ microk8s status
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    dns                  # (core) CoreDNS
    ha-cluster           # (core) Configure high availability on the current node
    helm                 # (core) Helm - the package manager for Kubernetes
    helm3                # (core) Helm 3 - the package manager for Kubernetes
  disabled:
    cert-manager         # (core) Cloud native certificate management
    cis-hardening        # (core) Apply CIS K8s hardening
    community            # (core) The community addons repository
    dashboard            # (core) The Kubernetes dashboard
    gpu                  # (core) Alias to nvidia add-on
    host-access          # (core) Allow Pods connecting to Host services smoothly
    hostpath-storage     # (core) Storage class; allocates storage from host directory
    ingress              # (core) Ingress controller for external access
    kube-ovn             # (core) An advanced network fabric for Kubernetes
    mayastor             # (core) OpenEBS MayaStor
    metallb              # (core) Loadbalancer for your Kubernetes cluster
    metrics-server       # (core) K8s Metrics Server for API access to service metrics
    minio                # (core) MinIO object storage
    nvidia               # (core) NVIDIA hardware (GPU and network) support
    observability        # (core) A lightweight observability stack for logs, traces and metrics
    prometheus           # (core) Prometheus operator for monitoring and logging
    rbac                 # (core) Role-Based Access Control for authorisation
    registry             # (core) Private image registry exposed on localhost:32000
    rook-ceph            # (core) Distributed Ceph storage using Rook
    storage              # (core) Alias to hostpath-storage add-on, deprecated
[vega@fedora ~]$ 
```

2. Установить dashboard.
```
[vega@fedora ~]$ microk8s enable dashboard
```
3. Сгенерировать сертификат для подключения к внешнему ip-адресу
```
[vega@fedora ~]$ sudo nano /var/snap/microk8s/current/certs/csr.conf.template 
```
Добавил строку:
```
IP.3 = 130.193.54.232
```
Обновил сертификат:
```
[vega@fedora ~]$ sudo microk8s refresh-certs --cert front-proxy-client.crt
Taking a backup of the current certificates under /var/snap/microk8s/6539/certs-backup/
Creating new certificates
Signature ok
subject=CN = front-proxy-client
Getting CA Private Key
Restarting service kubelite.
[vega@fedora ~]$ 
```
## Задание 2. Установка и настройка локального kubectl

1. Установить на локальную машину kubectl.
2. Настроить локально подключение к кластеру.
```
Получил данные кластера microk8s на удаленной машине:
[vega@fedora ~]$ sudo microk8s config
...
Потом внес параметры cluster, user и context на локальной машине
vega@vegaVM ~ % sudo vim .kube/config
vega@vegaVM ~ % kubectl config get-contexts
CURRENT   NAME             CLUSTER            AUTHINFO         NAMESPACE
*         docker-desktop   docker-desktop     docker-desktop
          microk8s         microk8s-cluster   admin
vega@vegaVM ~ % kubectl config use-context microk8s
Switched to context "microk8s".
vega@vegaVM ~ % kubectl get nodes
NAME          STATUS   ROLES    AGE   VERSION
fedora   Ready    <none>   75m   v1.28.1
```
3. Подключился к дашборду с помощью port-forward.
```
[vega@fedora ~]$ kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address 0.0.0.0
```
![image](https://github.com/busuek/netology/assets/101875725/293a4711-0973-4f7d-b146-5cae2b8dce2d)
