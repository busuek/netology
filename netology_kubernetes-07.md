# Домашнее задание к занятию «Хранение в K8s. Часть 2»

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке NFS в MicroK8S](https://microk8s.io/docs/nfs). 
2. [Описание Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
3. [Описание динамического провижининга](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/). 
4. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.  
Создал [Deployment](https://github.com/busuek/netology/blob/main/yml/multitool.yaml)  
```bash
ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl apply -f multitool.yaml
deployment.apps/multitool created
ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
multitool-74cc4b9bdd-fgmxr   0/2     Pending   0          17s
```

2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.  
Создал [PV](https://github.com/busuek/netology/blob/main/yml/pv.yaml) и [PVC](https://github.com/busuek/netology/blob/main/yml/pvc.yaml)  
```bash

ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl apply -f pvc.yaml
persistentvolumeclaim/pvc created
ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl get pvc
NAME   STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc    Pending                                                     6s
```
И только после создания `PV` запустился `Pod` и `PVC`  
```bash
ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl get pod
NAME                             READY   STATUS    RESTARTS   AGE
pod/multitool-74cc4b9bdd-fgmxr   2/2     Running   0          7m28s

ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl get pvc
NAME   STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc    Bound    pv       2Gi        RWO                           4m59s
ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl get pv
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM         STORAGECLASS   REASON   AGE
pv     2Gi        RWO            Delete           Bound    default/pvc                           54s
```


3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории.   
```bash
ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl exec -c busybox multitool-74cc4b9bdd-fgmxr -- ls -la
total 52
drwxr-xr-x    1 root     root          4096 Mar  21 12:23 .
drwxr-xr-x    1 root     root          4096 Mar  21 12:23 ..
drwxr-xr-x    2 root     root         12288 Mar  14 23:15 bin
drwxr-xr-x    5 root     root           360 Mar  21 12:23 dev
drwxr-xr-x    1 root     root          4096 Mar  17 12:23 etc
drwxr-xr-x    2 nobody   nobody        4096 Mar  21 18:39 home
drwxr-xr-x    2 root     root          4096 Mar  17 23:15 lib
lrwxrwxrwx    1 root     root             3 Mar  3 23:15 lib64 -> lib
drwxrwxrwx    2 nobody   nobody        4096 Mar  9 12:23 output
dr-xr-xr-x  272 root     root             0 Mar  9 12:23 proc
drwx------    2 root     root          4096 Mar 21 18:39 root
dr-xr-xr-x   13 root     root             0 Mar  9 12:23 sys
drwxrwxrwt    2 root     root          4096 Mar 21 18:39 tmp
drwxr-xr-x    4 root     root          4096 Mar 21 18:39 usr
drwxr-xr-x    1 root     root          4096 Mar  9 12:23 var


ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl exec -c busybox multitool-74cc4b9bdd-fgmxr -- ls -la /output
total 12
drwxrwxrwx    2 nobody   nobody        4096 Mar  21 12:23 .
drwxr-xr-x    1 root     root          4096 Mar  21 12:23 ..
-rw-r--r--    1 root     root            91 Mar  21 12:25 file.txt

ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl exec -c busybox multitool-74cc4b9bdd-fgmxr -- cat /output/file.txt
Write!
Write!
Write!
Write!
Write!
Write!
Write!

ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl exec -c multitool multitool-74cc4b9bdd-fgmxr -- ls -la
total 84
drwxr-xr-x    1 root     root          4096 Mar 21 12:23 .
drwxr-xr-x    1 root     root          4096 Mar 21 12:23 ..
drwxr-xr-x    1 root     root          4096 Mar 21  2021 bin
drwx------    2 root     root          4096 Mar 14  2021 certs
drwxr-xr-x    5 root     root           360 Mar 13 12:23 dev
drwxr-xr-x    1 root     root          4096 Dec 19  2021 docker
drwxr-xr-x    1 root     root          4096 Mar  9 12:23 etc
drwxr-xr-x    2 root     root          4096 Mar 21  2021 home
drwxr-xr-x    1 root     root          4096 Mar 19  2021 lib
drwxr-xr-x    5 root     root          4096 Mar 21  2021 media
drwxr-xr-x    2 root     root          4096 Mar 21  2021 mnt
drwxrwxrwx    2 nobody   nobody        4096 Mar  9 12:23 multitool
drwxr-xr-x    2 root     root          4096 Mar 21  2021 opt
dr-xr-xr-x  270 root     root             0 Mar  9 12:23 proc
drwx------    2 root     root          4096 Mar 21  2021 root
drwxr-xr-x    1 root     root          4096 Mar  9 12:23 run
drwxr-xr-x    1 root     root          4096 Mar 19  2021 sbin
drwxr-xr-x    2 root     root          4096 Mar 24  2021 srv
dr-xr-xr-x   13 root     root             0 Mar  9 12:23 sys
drwxrwxrwt    2 root     root          4096 Mar 21  2021 tmp
drwxr-xr-x    1 root     root          4096 Mar 19  2021 usr
drwxr-xr-x    1 root     root          4096 Mar 19  2021 var
ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl exec -c multitool multitool-74cc4b9bdd-fgmxr -- cat /multitool/file.txt
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
```

4. Продемонстрировать, что файл сохранился на локальном диске ноды, а также что произойдёт с файлом после удаления пода и deployment. Пояснить, почему.  
Захожу на саму машину с `microk8s` и проверяю файл  
```bash
ubuntu@ubuntu-VirtualBox:~/.kube$ ssh 158.160.14.41
buntu@k8s:~$ sudo -i
root@k8s:~# cd /srv/nfs
root@k8s:/srv/nfs# ls
file.txt
root@k8s:/srv/nfs# cat file.txt
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
Write!
```
А теперь удаляю `Deployment` вместе с `Pod` и проверяю тот же файл.  
```bash
ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl delete deployment multitool
deployment.apps "multitool" deleted


ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl get pod
No resources found in default namespace.
ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl get all
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   8d
```
```bash
root@k8s:/srv/nfs# ls
file.txt
root@k8s:/srv/nfs# cat file.txt
Write!
Write!
Write!
.........
```
Файл не удалился. Потому `Volume` был размещен за пределами `Pod-a`, поэтому данные сохранились после удаления `Deployment-a` и `Pod-a`   
Так же после удаления `PV` и `PVC` файл остался. И даже когда если указали `RaclaimPolicy: Delete` - файл остался, потому что `Delete` - это удаление ресурсов из внешних провайдеров (только в облачных Storage)  

5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.  

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.  
Скачиваю и настраиваю сервер `nfs`  
```bash
ubuntu@k8s:~$ sudo apt install nfs-kernel-server
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following packages were automatically installed and are no longer required:
  libflashrom1 libftdi1-2
Use 'sudo apt autoremove' to remove them.
The following additional packages will be installed:
  keyutils libnfsidmap1 nfs-common rpcbind
Suggested packages:
  watchdog

ubuntu@k8s:~$ sudo mkdir -p /srv/nfs
ubuntu@k8s:~$ sudo chown nobody:nogroup /srv/nfs
ubuntu@k8s:~$ sudo chmod 0777 /srv/nfs
ubuntu@k8s:~$ cat /etc/exports

ubuntu@k8s:~$ sudo nano /etc/exports
ubuntu@k8s:~$ sudo mv /etc/exports /etc/exports.bak
ubuntu@k8s:~$ echo 'srv/nfs *(rw,sync,no_subtree_check)' | sudo tee /etc/exports
srv/nfs *(rw,sync,no_subtree_check)
ubuntu@k8s:~$ sudo systemctl restart nfs-server

buntu@k8s:~$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/lib/systemd/system/nfs-server.service; enabled; vendor preset: enabled)
     Active: active (exited) since Sun 2023-04-09 11:56:41 UTC; 1min 45s ago
    Process: 614279 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 614280 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
   Main PID: 614280 (code=exited, status=0/SUCCESS)
        CPU: 5ms

Mar 21 11:56:41 k8s systemd[1]: Starting NFS server and services...
Mar 21 11:56:41 k8s systemd[1]: Finished NFS server and services.
```
И не забываю настроить драйвер `csi`  
```bash

root@k8s:~# microk8s enable helm3
Infer repository core for addon helm3
Addon core/helm3 is already enabled
root@k8s:~# microk8s helm3 repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
Error: looks like "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts" is not a valid chart repository or cannot be reached: failed to fetch https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts/index.yaml : 503 Service Unavailable
root@k8s:~# microk8s helm3 repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
"csi-driver-nfs" has been added to your repositories
root@k8s:~# microk8s helm3 repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "csi-driver-nfs" chart repository
Update Complete. ⎈Happy Helming!⎈

root@k8s:~# microk8s helm3 install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
    --namespace kube-system \
    --set kubeletDir=/var/snap/microk8s/common/var/lib/kubelet
NAME: csi-driver-nfs
LAST DEPLOYED: Sun Mar 21 13:31:10 2024
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The CSI NFS Driver is getting deployed to your cluster.

To check CSI NFS Driver pods status, please run:

  kubectl --namespace=kube-system get pods --selector="app.kubernetes.io/instance=csi-driver-nfs" --watch

root@k8s:~# microk8s kubectl wait pod --selector app.kubernetes.io/name=csi-driver-nfs --for condition=ready --namespace kube-system
pod/csi-nfs-controller-f9bd9cfc-xj2rv condition met
pod/csi-nfs-node-tj4vv condition met

root@k8s:~# microk8s kubectl get csidrivers
NAME             ATTACHREQUIRED   PODINFOONMOUNT   STORAGECAPACITY   TOKENREQUESTS   REQUIRESREPUBLISH   MODES        AGE
nfs.csi.k8s.io   false            false            false             <unset>         false               Persistent   62s
root@k8s:~# 
```


2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.  
Создал [Deployment](https://github.com/busuek/netology/blob/main/yml/multitoolPV.yaml)  
[PV](https://github.com/busuek/netology/blob/main/yml/pvc2.yaml)  
[SC](https://github.com/busuek/netology/blob/main/yml/sc.yaml)  
Проверяю запуск
```bash
ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl get pod,pvc,pv,sc
NAME                             READY   STATUS    RESTARTS   AGE
pod/multitool-78dbc6f4b4-5wtrx   1/1     Running   0          41m

NAME                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pvc   Bound    pvc-d1aafdb7-a30e-42aa-9330-21489e254a44   1Gi        RWO            my-nfs         41m

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM         STORAGECLASS   REASON   AGE
persistentvolume/pvc-d1aafdb7-a30e-42aa-9330-21489e254a44   1Gi        RWO            Delete           Bound    default/pvc   my-nfs                  78s

NAME                                 PROVISIONER      RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
storageclass.storage.k8s.io/my-nfs   nfs.csi.k8s.io   Delete          Immediate           false                  11m
```

3. Продемонстрировать возможность чтения и записи файла изнутри пода.  
Захожу в `Pod` чтобы создать файл.  
```bash
ubuntu@ubuntu-VirtualBox:~/.kube$ kubectl exec multitool-78dbc6f4b4-5wtrx -it -- sh
/ #
/ #
/ # ls
bin        dev        etc        lib        mnt        opt        root       sbin       sys        usr
certs      docker     home       media      multitool  proc       run        srv        tmp        var
/ # cd multitool
/multitool # ls
/multitool # touch 1234test.txt
/multitool # echo 4312ase > 1234test.txt
/multitool # cat 1234test.txt
4312ase
/multitool # exit
```
Возвращаюсь на машину с `mirok8s` чтобы увидеть этот файл.  
И обнаруживаю что в директории, которую "расшаривал" появился `Volum`, внутри которого созданный файл `1234test.txt`  
```bash
ubuntu@ubuntu-VirtualBox:~/.kube$ ssh 158.160.14.41


root@k8s:~# ls /srv/nfs
file.txt  pvc-d1aafdb7-a30e-42aa-9330-21489e254a44
root@k8s:~# ls /srv/nfs/pvc-d1aafdb7-a30e-42aa-9330-21489e254a44/
1234test.txt
root@k8s:~# cat /srv/nfs/pvc-d1aafdb7-a30e-42aa-9330-21489e254a44/1234test.txt
4312ase
```

4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.  

------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
