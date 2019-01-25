#!/bin/bash

    kubectl create -f  redis-slave-deployment.yaml
    kubectl create -f  redis-slave-service.yaml
    kubectl create -f  redis-master-deployment.yaml
    kubectl create -f  redis-master-service.yaml
    kubectl create -f  frontend-deployment.yaml
    kubectl create -f  frontend-service.yaml


