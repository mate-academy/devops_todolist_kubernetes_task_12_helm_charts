#!/bin/bash
helm install todoapp helm-charts/todoapp
helm upgrade todoapp helm-charts/todoapp -f helm-charts/todoapp/values.yaml -f helm-charts/todoapp/charts/mysql/values.yaml