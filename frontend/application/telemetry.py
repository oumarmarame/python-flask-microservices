"""
Instrumentation OpenTelemetry pour le service Frontend Flask.
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

# Imports pour configuration manuelle (j'utilise le SDK directement)
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
# Exportateur OTLP/GRPC pour envoyer les traces à mon collecteur
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource, SERVICE_NAME

from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor

# Imports pour la journalisation (désactivé pour l'instant - problème de dépendance)
# from opentelemetry.sdk.logs import LoggerProvider, LoggingHandler
# from opentelemetry.sdk.logs.export import BatchLogRecordProcessor
# from opentelemetry.exporter.otlp.proto.grpc.log_exporter import OTLPLogExporter
# import logging

def configure_telemetry(app: Flask, service_name: str):
    """
    Configure OpenTelemetry MANUELLEMENT pour ce service Flask.
    
    J'ai choisi de coder l'instrumentation manuellement avec le SDK plutôt que
    d'utiliser l'auto-instrumentation pour avoir un contrôle total sur :
    - Le nom du service (service_name)
    - L'endpoint du collecteur (OTEL_EXPORTER_OTLP_ENDPOINT)
    - Les processors (BatchSpanProcessor pour optimiser les performances)
    
    Cette fonction initialise le SDK, configure l'exportateur OTLP/GRPC et applique
    l'instrumentation automatique pour Flask et Requests.
    """
    # --- Configuration commune ---
    # Je lis l'endpoint du collecteur depuis l'environnement (défini dans docker-compose.yml)
    otlp_grpc_endpoint = os.environ.get("OTEL_EXPORTER_OTLP_ENDPOINT", "otel-collector:4317")
    resource = Resource(attributes={SERVICE_NAME: service_name})

    # --- Configuration du Traçage (Tracing) ---
    # Je crée un TracerProvider avec le nom du service
    tracer_provider = TracerProvider(resource=resource)
    # J'utilise BatchSpanProcessor pour grouper les spans et réduire la charge réseau
    trace_processor = BatchSpanProcessor(OTLPSpanExporter(endpoint=otlp_grpc_endpoint, insecure=True))
    tracer_provider.add_span_processor(trace_processor)
    trace.set_tracer_provider(tracer_provider)

    # --- Configuration de la Journalisation (Logging) ---
    # Désactivé temporairement à cause du problème "ModuleNotFoundError: No module named 'opentelemetry.sdk.logs'"
    # Je garde le code commenté pour référence future
    # logger_provider = LoggerProvider(resource=resource)
    # log_processor = BatchLogRecordProcessor(OTLPLogExporter(endpoint=otlp_grpc_endpoint, insecure=True))
    # logger_provider.add_log_record_processor(log_processor)

    # # Intégration avec le module logging de Python
    # handler = LoggingHandler(level=logging.INFO, logger_provider=logger_provider)
    # logging.getLogger().addHandler(handler)
    
    # --- Instrumentation automatique ---
    # J'instrumente Flask pour capturer automatiquement toutes les requêtes HTTP
    FlaskInstrumentor().instrument_app(app)
    # J'instrumente Requests pour tracer les appels HTTP sortants vers les autres microservices
    RequestsInstrumentor().instrument()

    print(f"✅ [Observabilité] Instrumentation OpenTelemetry activée pour '{service_name}'")
    print(f"📡 [Observabilité] Exportation Traces vers OTLP Collector (gRPC) : {otlp_grpc_endpoint}")
