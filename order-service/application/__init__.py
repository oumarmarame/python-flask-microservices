# application/__init__.py
import config
import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
# Importe notre nouvelle fonction de configuration
from application.telemetry import configure_telemetry

db = SQLAlchemy()


def create_app():
    app = Flask(__name__)
    environment_configuration = os.environ['CONFIGURATION_SETUP']
    app.config.from_object(environment_configuration)

    db.init_app(app)

    # --- DEBUT Instrumentation OpenTelemetry ---
    configure_telemetry(app, "order-service")
    # --- FIN Instrumentation OpenTelemetry ---

    with app.app_context():
        from .order_api import order_api_blueprint
        app.register_blueprint(order_api_blueprint)
        return app
