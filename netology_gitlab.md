# Домашнее задание к занятию 12 «GitLab»

## Подготовка к выполнению

1. Подготовьте к работе GitLab [по инструкции](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/gitlab-containers).
2. Создайте свой новый проект.
3. Создайте новый репозиторий в GitLab, наполните его [файлами](./repository).
4. Проект должен быть публичным, остальные настройки по желанию.

## Основная часть

### DevOps

В репозитории содержится код проекта на Python. Проект — RESTful API сервис. Ваша задача — автоматизировать сборку образа с выполнением python-скрипта:

1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated).
2. Python версии не ниже 3.7.
3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`.
4. Создана директория `/python_api`.
5. Скрипт из репозитория размещён в /python_api.
6. Точка вызова: запуск скрипта.
7. При комите в любую ветку должен собираться docker image с форматом имени hello:gitlab-$CI_COMMIT_SHORT_SHA . Образ должен быть выложен в Gitlab registry или yandex registry.   
8.* (задание необязательное к выполению) При комите в ветку master после сборки должен подняться pod в kubernetes. Примерный pipeline для push в kubernetes по [ссылке](https://github.com/awertoss/devops-netology/blob/main/09-ci-06-gitlab/gitlab-ci.yml).
Если вы еще не знакомы с k8s - автоматизируйте сборку и деплой приложения в docker на виртуальной машине.

### Решение:

![9_6_1](https://github.com/busuek/netology/assets/101875725/4da74464-fd3a-42d6-8483-2386944e7c29)

### Product Owner

Вашему проекту нужна бизнесовая доработка: нужно поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:

1. Какой метод необходимо исправить.
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`.
3. Issue поставить label: feature.

### Решение:

![9_6_2](https://github.com/busuek/netology/assets/101875725/aa24ab4c-8fca-4422-897e-e47a50f3fadc)

### Developer

Пришёл новый Issue на доработку, вам нужно:

1. Создать отдельную ветку, связанную с этим Issue.
2. Внести изменения по тексту из задания.
3. Подготовить Merge Request, влить необходимые изменения в `master`, проверить, что сборка прошла успешно.

### Решение:

![9_6_3](https://github.com/busuek/netology/assets/101875725/ef03c551-24e8-4215-8533-0c15227dfc64)

![9_6_4](https://github.com/busuek/netology/assets/101875725/19bf2331-43a3-454b-b3d5-e9547dc351f3)

![9_6_5](https://github.com/busuek/netology/assets/101875725/c65b6020-3b82-48a5-8b92-97fdbb44e771)


### Tester

Разработчики выполнили новый Issue, необходимо проверить валидность изменений:

1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность.
2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый.

### Решение:

```bash
root@gitlab-runner-1:/# docker run --rm -d -p "5290:5290" gitlab.it-git.ru:5050/test/test/hello:gitlab-62e4a4b1
9eb2180767463fa772cad98d8cf26339b8c27aafc22d182b746b9bd107d94f7a
root@gitlab-runner-1:/# docker ps -a
CONTAINER ID   IMAGE                                    COMMAND                  CREATED         STATUS         PORTS                                       NAMES
9eb218076746   gitlab.it-git.ru:5050/test/test/hello:gitlab-62e4a4b1   "python3 /python_api…"   5 seconds ago   Up 4 seconds   0.0.0.0:5290->5290/tcp, :::5290->5290/tcp   blissful_hopper
root@gitlab-runner-1:/# curl http://localhost:5290/rest/api/get_info
{"version": 3, "method": "GET", "message": "Running"}
root@gitlab-runner-1:/#
```

![9_6_6](https://github.com/busuek/netology/assets/101875725/52004ef0-9141-489e-adad-d7e9597125c5)

## Итог

В качестве ответа пришлите подробные скриншоты по каждому пункту задания:

- файл gitlab-ci.yml;
- Dockerfile; 
- лог успешного выполнения пайплайна;
- решённый Issue.

<details><summary>gitlab-ci.yml</summary>

```yaml

stages:
  - build
  - test
  - deploy
image: docker
services:
  - docker
builder:
  stage: build
  script:
    - docker build --squash -t $CI_REGISTRY/$CI_PROJECT_PATH/hello:gitlab-$CI_COMMIT_SHORT_SHA .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY/$CI_PROJECT_PATH/hello:gitlab-$CI_COMMIT_SHORT_SHA
  except:
    - main
deployer:
  stage: deploy
  script:
    - docker build -t $CI_REGISTRY/$CI_PROJECT_PATH:latest .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY/$CI_PROJECT_PATH:latest
  only:
    - main

```

</details>

<details><summary>Dockerfile</summary>

```Dockerfile

FROM centos:7
ENV PYTHON_VERSION=3.7.5
EXPOSE 5290 5290

RUN yum install -y gcc openssl-devel bzip2-devel libffi libffi-devel curl wget make && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz  && \
    tar -xzf Python-${PYTHON_VERSION}.tgz && rm Python-${PYTHON_VERSION}.tgz && \
    yum clean all && rm -rf /var/cache/yum/*

WORKDIR /Python-${PYTHON_VERSION}

RUN ./configure --enable-optimizations && \
    make altinstall && \
    ln -sf /usr/local/bin/python3.7 /usr/bin/python3 && \
    cd / && rm -rf /Python-${PYTHON_VERSION}

COPY requirements.txt /tmp/
RUN python3 -m pip install -r /tmp/requirements.txt

ADD python-api.py /python_api/python-api.py

ENTRYPOINT ["python3", "/python_api/python-api.py"]

```


</details>

<details><summary>Пайплайн</summary>

```bash
[0KRunning with gitlab-runner 16.2.1 (674e0e29)[0;m
[0K  on gitlab-runner-1 sCSnWsW_V, system ID: s_3b0069d0acea[0;m
section_start:1692280742:prepare_executor
[0K[0K[36;1mPreparing the "shell" executor[0;m[0;m
[0KUsing Shell (bash) executor...[0;m
section_end:1692280742:prepare_executor
[0Ksection_start:1692280742:prepare_script
[0K[0K[36;1mPreparing environment[0;m[0;m
Running on gitlab-runner-1...
section_end:1692280742:prepare_script
[0Ksection_start:1692280742:get_sources
[0K[0K[36;1mGetting source from Git repository[0;m[0;m
[32;1mFetching changes with git depth set to 20...[0;m
Reinitialized existing Git repository in /home/gitlab-runner/builds/sCSnWsW_V/0/test/test/.git/
[32;1mChecking out 62e4a4b1 as detached HEAD (ref is 2-get_info)...[0;m
[32;1mSkipping Git submodules setup[0;m
section_end:1692280742:get_sources
[0Ksection_start:1692280742:step_script
[0K[0K[36;1mExecuting "step_script" stage of the job script[0;m[0;m
[32;1m$ docker build --squash -t $CI_REGISTRY/$CI_PROJECT_PATH/hello:gitlab-$CI_COMMIT_SHORT_SHA .[0;m
WARNING: experimental flag squash is removed with BuildKit. You should squash inside build using a multi-stage Dockerfile for efficiency.
#0 building with "default" instance using docker driver

#1 [internal] load .dockerignore
#1 transferring context: 2B done
#1 DONE 0.0s

#2 [internal] load build definition from Dockerfile
#2 transferring dockerfile: 794B done
#2 DONE 0.0s

#3 [internal] load metadata for docker.io/library/centos:7
#3 DONE 1.4s

#4 [1/7] FROM docker.io/library/centos:7@sha256:be65f488b7764ad3638f236b7b515b3678369a5124c47b8d32916d6487418ea4
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 479B done
#5 DONE 0.0s

#6 [2/7] RUN yum install -y gcc openssl-devel bzip2-devel libffi libffi-devel curl wget make &&     wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tgz  &&     tar -xzf Python-3.7.5.tgz && rm Python-3.7.5.tgz &&     yum clean all && rm -rf /var/cache/yum/*
#6 CACHED

#7 [5/7] COPY requirements.txt /tmp/
#7 CACHED

#8 [4/7] RUN ./configure --enable-optimizations &&     make altinstall &&     ln -sf /usr/local/bin/python3.7 /usr/bin/python3 &&     cd / && rm -rf /Python-3.7.5
#8 CACHED

#9 [3/7] WORKDIR /Python-3.7.5
#9 CACHED

#10 [6/7] RUN python3 -m pip install -r /tmp/requirements.txt
#10 CACHED

#11 [7/7] ADD python-api.py /python_api/python-api.py
#11 DONE 0.0s

#12 exporting to image
#12 exporting layers done
#12 writing image sha256:027a58049bbade25eb35151a9bdb44d4c0ddf15bb4c17b7ab6a6b12eebaa8411 done
#12 naming to gitlab.it-git.ru:5050/test/test/hello:gitlab-62e4a4b1 done
#12 DONE 0.0s
[32;1m$ docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY[0;m
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /home/gitlab-runner/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
[32;1m$ docker push $CI_REGISTRY/$CI_PROJECT_PATH/hello:gitlab-$CI_COMMIT_SHORT_SHA[0;m
The push refers to repository [gitlab.it-git.ru:5050/test/test/hello]
f041497ab66f: Preparing
27478353c7d3: Preparing
77517d9af65f: Preparing
e7412d44d0b0: Preparing
5f70bf18a086: Preparing
1c469ea1066c: Preparing
174f56854903: Preparing
1c469ea1066c: Waiting
174f56854903: Waiting
5f70bf18a086: Layer already exists
e7412d44d0b0: Layer already exists
77517d9af65f: Layer already exists
27478353c7d3: Layer already exists
1c469ea1066c: Layer already exists
174f56854903: Layer already exists
f041497ab66f: Pushed
gitlab-62e4a4b1: digest: sha256:59713cc39a23818c0b39e04206c281e46cfe1b8dbf67577f04cc63f03ec82c04 size: 1784
section_end:1692280744:step_script
[0Ksection_start:1692280744:cleanup_file_variables
[0K[0K[36;1mCleaning up project directory and file based variables[0;m[0;m
section_end:1692280744:cleanup_file_variables
[0K[32;1mJob succeeded[0;m

```

</details>

<details><summary>Issue</summary>

![9_6_7](https://github.com/busuek/netology/assets/101875725/3511f7f9-62a4-4fb5-b32d-165082ddbf61)

</details>
