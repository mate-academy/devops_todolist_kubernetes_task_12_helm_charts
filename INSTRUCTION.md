# Інструкція з валідації інфраструктури ToDo App

## Кроки перевірки:
1. Переконайтеся, що всі компоненти (Pod, Service, HPA) запущено:
   ```bash
   kubectl get all -n todoapp
   ```
2. Перевірте статус Taints на нодах:
   ```bash
   kubectl describe nodes | grep -i taint
   ```
