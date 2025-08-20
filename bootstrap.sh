#!/bin/bash
helm install todoapp helm-chart/todoapp
helm upgrade todoapp helm-chart/todoapp -f helm-chart/todoapp/values.yaml -f helm-chart/todoapp/charts/mysql/values.yaml