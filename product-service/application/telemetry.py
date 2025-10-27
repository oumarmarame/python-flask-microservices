"""
Instrumentation OpenTelemetry pour le service Product Flask.
Ce module configure le traçage distribué et les métriques via OpenTelemetry SDK.

@author: Oumar Marame Ndione
Courriel: oumar-marame.ndione.1@ens.etsmtl.ca
Code Permanent: Private

Cours: MGL870 - Automne 2025
Enseignant: Fabio Petrillo
Projet 1: Mise en Œuvre d'un Pipeline de Journalisation, Traçage et Métriques avec OpenTelemetry
École de technologie supérieure (ÉTS)
@version: 2025-10-26
"""

import os
from flask import Flask

# Imports pour configuration manuelle
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
# Importation pour l'exportateur OTLP/GRPC
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource, SERVICE_NAME

from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor

# Imports pour la journalisation (Logging)
# from opentelemetry.sdk.logs import LoggerProvider, LoggingHandler
# from opentelemetry.sdk.logs.export import BatchLogRecordProcessor
# from opentelemetry.exporter.otlp.proto.grpc.log_exporter import OTLPLogExporter
# import logging

def configure_telemetry(app: Flask, service_name: str): # Ajout du paramètre service_name
    """
    Configure OpenTelemetry MANUELLEMENT pour ce service Flask.

    Initialise le SDK, configure l'exportateur OTLP/GRPC et applique
    l'instrumentation automatique pour Flask et Requests.
    """
    # --- Configuration commune ---
    otlp_grpc_endpoint = os.environ.get("OTEL_EXPORTER_OTLP_ENDPOINT", "otel-collector:4317")
    resource = Resource(attributes={SERVICE_NAME: service_name})

    # --- Configuration du Traçage (Tracing) ---
    tracer_provider = TracerProvider(resource=resource)
    trace_processor = BatchSpanProcessor(OTLPSpanExporter(endpoint=otlp_grpc_endpoint, insecure=True))
    tracer_provider.add_span_processor(trace_processor)
    trace.set_tracer_provider(tracer_provider)

    # --- Configuration de la Journalisation (Logging) ---
    # logger_provider = LoggerProvider(resource=resource)
    # log_processor = BatchLogRecordProcessor(OTLPLogExporter(endpoint=otlp_grpc_endpoint, insecure=True))
    # logger_provider.add_log_record_processor(log_processor)

    # # Intégration avec le module logging de Python
    # handler = LoggingHandler(level=logging.INFO, logger_provider=logger_provider)
    # logging.getLogger().addHandler(handler)
    
    # --- Instrumentation automatique ---
    FlaskInstrumentor().instrument_app(app)
    RequestsInstrumentor().instrument()

    print(f"--- [Observabilité] Instrumentation OpenTelemetry (manuelle SDK) activée pour '{service_name}' ---")
    print(f"--- [Observabilité] Exportation Traces & Logs vers OTLP Collector (GRPC) à {otlp_grpc_endpoint} ---")
