#!/bin/bash

helm dependency update ./.infrastructure/helm-chart/todoapp
helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp -n todoapp --create-namespace
