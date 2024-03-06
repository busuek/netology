# Домашнее задание к занятию «Базовые объекты K8S».

- Цель задания : В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Pod с приложением и подключиться к нему со своего локального компьютера.

## Задание 1. Создать Pod с именем hello-world.

- Создать манифест (yaml-конфигурацию) Pod.
- Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
- Подключиться локально к Pod с помощью kubectl port-forward и вывести значение (curl или в браузере).
```
[vega@fedora ~]$ kubectl version --client
Client Version: v1.28.2
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
[vega@fedora 1.2]$ sudo nano hello-world-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  containers:
    - name: echoserver
      image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
      ports:
        - containerPort: 8080
```

Применяем манифест с помощью kubectl:
```
[vega@fedora 1.2]$ kubectl apply -f hello-world-pod.yaml
pod/hello-world created
Pod запущен, мы можем использовать kubectl port-forward, чтобы установить прямое соединение к Pod: - запускаем во втором окне
devops@WORKBOOK:/mnt/c/kube$ kubectl port-forward hello-world 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

Вывод на экран:
```
[vega@fedora 1.2]$ curl http://localhost:8080
Hostname: hello-world
Pod Information:
        -no pod information available-
Server values:
        server_version=nginx: 1.12.2 - lua: 10010
Request Information:
        client_address=127.0.0.1
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://localhost:8080/
Request Headers:
        accept=*/*
        host=localhost:8080
        user-agent=curl/7.81.0
Request Body:
        -no body in request-
```

![Снимок11](https://github.com/busuek/netology/assets/101875725/c4663c68-1112-4f54-ba85-47bd4484d638)

## Задание 2. Создать Service и подключить его к Pod.

- Создать Pod с именем netology-web.
- Использовать image — gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
- Создать Service с именем netology-svc и подключить к netology-web.
- Подключиться локально к Service с помощью kubectl port-forward и вывести значение (curl или в браузере).
- [web.yml](https://github.com/busuek/netology/blob/main/netology-web-pod)
- [svc.yml](https://github.com/busuek/netology/blob/main/netology-svc)
```
[vega@fedora 1.2]$ sudo nano netology-web-pod.yaml 
[vega@fedora 1.2]$ kubectl apply -f netology-web-pod.yaml
pod/netology-web created
[vega@fedora 1.2]$ sudo nano netology-svc.yaml 
[vega@fedora 1.2]$ kubectl apply -f netology-svc.yaml
service/netology-svc created
[vega@fedora 1.2]$ kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
hello-world    1/1     Running   0          18m
netology-web   1/1     Running   0          5m4s
[vega@fedora 1.2]$ microk8s kubectl get svc netology-svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
netology-svc   ClusterIP   10.152.183.97   <none>        80/TCP    57m
```

![portf](https://github.com/busuek/netology/assets/101875725/ddeaba47-0a93-47cc-becd-6e2f9203fcb0)
