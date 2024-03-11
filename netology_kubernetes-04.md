# Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 1»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к приложению, установленному в предыдущем ДЗ и состоящему из двух контейнеров, по разным портам в разные контейнеры как внутри кластера, так и снаружи.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Описание Service.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.

Конфиг: [deployment1.yaml](https://github.com/busuek/netology/blob/main/kuber-1.4/deployment1.yaml)

```
microk8s kubectl apply -f deployment1.yaml
deployment.apps/deployment created

 microk8s kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
deployment   3/3     3            3           33s

```

2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.

Конфиг: [service.yaml](https://github.com/busuek/netology/blob/main/kuber-1.4/service.yaml)

```
microk8s kubectl apply -f service.yaml
service/nginx-svc created

microk8s kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP             6d15h
nginx-svc    ClusterIP   10.152.183.143   <none>        9001/TCP,9002/TCP   44s

```

3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.

```
microk8s kubectl run multitool --image=wbitt/network-multitool
pod/multitool created

microk8s kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
deployment-db87957b8-slxkx   2/2     Running   0          4m6s
deployment-db87957b8-z9qph   2/2     Running   0          4m6s
deployment-db87957b8-tkffz   2/2     Running   0          4m6s
multitool                    1/1     Running   0          61s

 microk8s kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP             6d15h
nginx-svc    ClusterIP   10.152.183.143   <none>        9001/TCP,9002/TCP   5m8s

microk8s kubectl exec multitool -- curl 10.152.183.143:9002
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   144  100   144    0     0  65873      0 --:--:-- --:--:-- --:--:--  140k
WBITT Network MultiTool (with NGINX) - deployment-db87957b8-slxkx - 10.1.45.101 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)


```

4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.

```
microk8s kubectl exec multitool -- curl nginx-svc:9001
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0  50135      0 --:--:-- --:--:-- --:--:-- 55636
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>


```

5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4

```
Cмотреть выше.
```

------

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.

Конфиг: [service2.yaml](https://github.com/busuek/netology/blob/main/kuber-1.4/service2.yaml)

```
microk8s kubectl apply -f service2.yaml
service/nginx-svc2 created

microk8s kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP                         6d15h
nginx-svc    ClusterIP   10.152.183.143   <none>        9001/TCP,9002/TCP               17m
nginx-svc2   NodePort    10.152.183.240   <none>        9001:30001/TCP,9002:30002/TCP   63s


```
2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.

<p align="center">
  <img width="1200" src="https://github.com/busuek/netology/blob/main/kuber-1.4/welcome.jpg">
</p>

3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

```
Смотреть выше.
```

------
