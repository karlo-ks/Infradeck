# Standalone collector image: the collector uses only the Python standard library.
FROM python:3.12.16-alpine@sha256:c5ba3deef00c7758561a0f03c26f44f10589263d40e732b8748e0d1f38f6dd89

WORKDIR /app
COPY src/collector/collector.py ./collector.py
COPY VERSION ./VERSION

ENV INFRADECK_STATE_DIR=/var/lib/infradeck-collector \
    HOST_PROC=/host/proc \
    HOST_ROOT=/hostfs \
    DOCKER_SOCKET_PATH=/var/run/docker.sock \
    PYTHONUNBUFFERED=1

VOLUME ["/var/lib/infradeck-collector"]

CMD ["python", "/app/collector.py"]
