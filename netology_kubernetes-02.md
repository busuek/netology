# Домашнее задание к занятию «Базовые объекты K8S».

- Цель задания : В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Pod с приложением и подключиться к нему со своего локального компьютера.

## Задание 1. Создать Pod с именем hello-world.

- Создать манифест (yaml-конфигурацию) Pod.
- Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
- Подключиться локально к Pod с помощью kubectl port-forward и вывести значение (curl или в браузере).
```
devops@WORKBOOK:/mnt/c/kube$ kubectl version --client
Client Version: v1.28.2
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
devops@WORKBOOK:/mnt/c/kube/kuber-homeworks/1.2$ sudo nano hello-world-pod.yaml
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
