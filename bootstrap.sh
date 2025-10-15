#!/bin/bash

helm deploy chart with subcharts
helm dependency update ./helm-chart/todoapp
helm upgrade --install todoapp ./helm-chart/todoapp -n todoapp --create-namespace
