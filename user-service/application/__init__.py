# application/__init__.py
import config
import os
from flask import Flask
from flask_login import LoginManager
from flask_sqlalchemy import SQLAlchemy
# Importe notre nouvelle fonction de configuration
from application.telemetry import configure_telemetry

db = SQLAlchemy()
login_manager = LoginManager()


def create_app():
    app = Flask(__name__)
    environment_configuration = os.environ['CONFIGURATION_SETUP']
    app.config.from_object(environment_configuration)

    db.init_app(app)
    login_manager.init_app(app)

    # --- DEBUT Instrumentation OpenTelemetry ---
    # Applique la configuration d'observabilité à notre instance d'application
    configure_telemetry(app, "user-service")
    # --- FIN Instrumentation OpenTelemetry ---

    with app.app_context():
        # Register blueprints
        from .user_api import user_api_blueprint
        app.register_blueprint(user_api_blueprint)
        return app
