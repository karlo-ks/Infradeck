# Read-only Docker API proxy: the only container that mounts the Docker socket.
# Standard library only. See src/collector/docker_proxy.py for exactly what it allows.
FROM python:3.12.16-alpine@sha256:c5ba3deef00c7758561a0f03c26f44f10589263d40e732b8748e0d1f38f6dd89

WORKDIR /app
COPY src/collector/docker_proxy.py ./docker_proxy.py

ENV DOCKER_SOCKET_PATH=/var/run/docker.sock \
    INFRADECK_DOCKER_PROXY_SOCKET=/run/docker-proxy/docker.sock \
    PYTHONUNBUFFERED=1

USER 0:0
CMD ["python", "/app/docker_proxy.py"]
