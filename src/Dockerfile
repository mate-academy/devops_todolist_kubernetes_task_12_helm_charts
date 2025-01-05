# Stage 1: Build Stage
ARG PYTHON_VERSION=3.8
FROM python:${PYTHON_VERSION} as builder

WORKDIR /app

# Копіюємо файли з папки src
COPY src/ . 

# Stage 2: Run Stage
FROM python:${PYTHON_VERSION} as run

WORKDIR /app

# Копіюємо файли з попереднього етапу
COPY --from=builder /app . 

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Перевіряємо вміст директорії /app перед запуском Django
RUN ls -alh /app

EXPOSE 8080

RUN pip install mysqlclient

# Запускаємо Django з використанням manage.py
ENTRYPOINT ["sh", "-c", "python /app/manage.py migrate && python /app/manage.py runserver 0.0.0.0:8080"]
