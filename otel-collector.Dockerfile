# Dockerfile pour OTel Collector avec configuration embarquée
FROM otel/opentelemetry-collector-contrib:0.102.1

# Copier notre configuration dans le conteneur
COPY otel-collector-config.yaml /etc/otelcol-contrib/config.yaml

# Démarrer avec cette configuration
CMD ["--config=/etc/otelcol-contrib/config.yaml"]
