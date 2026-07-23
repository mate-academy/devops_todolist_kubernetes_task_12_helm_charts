#!/bin/bash
kind create cluster --config cluster.yml
helm dependency build helm-chart/todoapp
helm upgrade --install todoapp helm-chart/todoapp --namespace todoapp --create-namespace

