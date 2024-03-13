 # Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 2»

------

### Задание 1. Создать Deployment приложений backend и frontend

1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.
2. Создать Deployment приложения _backend_ из образа multitool. 
3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 
4. Продемонстрировать, что приложения видят друг друга с помощью Service.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

Решение:

 # Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 2»

------

### Задание 1. Создать Deployment приложений backend и frontend

1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.
2. Создать Deployment приложения _backend_ из образа multitool. 
3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 
4. Продемонстрировать, что приложения видят друг друга с помощью Service.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

Ответ:

1. Deployment приложения _frontend_ создан

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: depfront
  name: depfront
spec:
  selector:
    matchLabels:
      app: depfront
  replicas: 3
  template:
    metadata:
      labels:
        app: depfront
    spec:
      containers:
        - name: depfront
          image: nginx:1.14.2
          ports:
            - name: http
              containerPort: 80
```

2. Deployment приложения _backend_ создан

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: depback
  name: depback
spec:
  selector:
    matchLabels:
      app: depback
  replicas: 1 
  template:
    metadata:
      labels:
        app: depback
    spec:
      containers:
      - name: depback
        image: praqma/network-multitool
        env:
        - name: HTTP_PORT
          value: "1181"
        - name: HTTPS_PORT
          value: "11443"
        ports:
        - containerPort: 1181 
          name: http-port
        - containerPort: 11443
          name: https-port
        resources:
          requests:
            cpu: "1m"
            memory: "20Mi"
          limits:
            cpu: "10m"
            memory: "20Mi"
        securityContext:
          runAsUser: 0
          capabilities:
            add: ["NET_ADMIN"]
```
   
3. Service, которые обеспечат доступ к обоим приложениям внутри кластера создан

```
kind: Service
apiVersion: v1
metadata:
  name: servfront
spec:
  selector:
    app: depfront
  ports:
    - protocol: TCP
      port: 80
      targetPort: 1380
```
```
kind: Service
apiVersion: v1
metadata:
  name: servback
spec:
  selector:
    app: depback
  ports:
    - protocol: TCP
      port: 80
      targetPort: 1181
```
   
4. Из frontend подключаемся к backend

```
PS C:\Users\lugy1\.kube> kubectl exec --stdin --tty services/servfront -- /bin/bash
root@depfront-7647b8fc8f-wx7cg:/# curl http://servback
Praqma Network MultiTool (with NGINX) - depback-547bb598-nb5rn - 10.1.254.123 - HTTP: 1181 , HTTPS: 11443
<br>
<hr>
<br>

<h1>05 Jan 2022 - Press-release: `Praqma/Network-Multitool` is now `wbitt/Network-Multitool`</h1>    

<h2>Important note about name/org change:</h2>
<p>
Few years ago, I created this tool with Henrik Høegh, as `praqma/network-multitool`. Praqma was bought by another company, and now the "Praqma" brand is being dismantled. This means the network-multitool's git and docker repositories must go. Since, I was the one maintaining the docker image for all these years, it was decided by the current representatives of the company to hand it over to me so I can continue maintaining it. So, apart from a small change in the repository name, nothing has changed.<br>
</p>
<p>
The existing/old/previous container image `praqma/network-multitool` will continue to work and will remain available for **"some time"** - may be for a couple of months - not sure though.
</p>
<p>
- Kamran Azeem <kamranazeem@gmail.com> <a href=https://github.com/KamranAzeem>https://github.com/KamranAzeem</a>
</p>

<h2>Some important URLs:</h2>

<ul>
  <li>The new official github repository for this tool is: <a href=https://github.com/wbitt/Network-MultiTool>https://github.com/wbitt/Network-MultiTool</a></li>

  <li>The docker repository to pull this image is now: <a href=https://hub.docker.com/r/wbitt/network-multitool>https://hub.docker.com/r/wbitt/network-multitool</a></li>
</ul>

<br>
Or:
<br>

<pre>
  <code>
  docker pull wbitt/network-multitool
  </code>
</pre>


<hr>
```
5. Скриншот подключения

![image](https://github.com/LugovskoyPavel/devops-netology-2022/assets/104651372/21503a53-6cd5-4094-b4d4-fd0ad3b2533e)

------

### Задание 2. Создать Ingress и обеспечить доступ к приложениям снаружи кластера

1. Включить Ingress-controller в MicroK8S.
2. Создать Ingress, обеспечивающий доступ снаружи по IP-адресу кластера MicroK8S так, чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_.
3. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
4. Предоставить манифесты и скриншоты или вывод команды п.2.

Ответ:
1. Контроллер включен
```
microk8s enable ingress
Infer repository core for addon ingress
Enabling Ingress
ingressclass.networking.k8s.io/public created
ingressclass.networking.k8s.io/nginx created
namespace/ingress created
serviceaccount/nginx-ingress-microk8s-serviceaccount created
clusterrole.rbac.authorization.k8s.io/nginx-ingress-microk8s-clusterrole created
role.rbac.authorization.k8s.io/nginx-ingress-microk8s-role created
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress-microk8s created
rolebinding.rbac.authorization.k8s.io/nginx-ingress-microk8s created       
configmap/nginx-load-balancer-microk8s-conf created
configmap/nginx-ingress-tcp-microk8s-conf created
configmap/nginx-ingress-udp-microk8s-conf created
daemonset.apps/nginx-ingress-microk8s-controller created
Ingress is enabled
```

2. Ingress создан

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: lugnginx
  annotations: 
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-ingress
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: servfont
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: servback
            port:
              number: 80
```
```
PS C:\Users\lugy1\.kube> kubectl describe ingress lugnginx
Name:             lugnginx
Labels:           <none>
Namespace:        default
Address:
Ingress Class:    nginx-ingress
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *
              /      servfront:80 (10.1.254.126:1380,10.1.254.68:1380,10.1.254.69:1380)
              /api   servback:80 (10.1.254.123:1181)
Annotations:  <none>
Events:       <none>
```

3. Доступ получен

```
PS C:\Users\lugy1\.kube> kubectl exec --stdin --tty services/servfront -- /bin/bash
root@depfront-7647b8fc8f-wx7cg:/# curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
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
root@depfront-7647b8fc8f-wx7cg:/# curl localhost/api
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.25.1</center>
</body>
</html>
```
4. Скрин

![image](https://github.com/LugovskoyPavel/devops-netology-2022/assets/104651372/5dc9a302-45f0-4ee6-b033-f0869ea9aed3)

------
