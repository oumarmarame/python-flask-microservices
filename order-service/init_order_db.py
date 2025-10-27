#!/usr/bin/env python
"""Initialize order database tables."""

from application import create_app, db
from application.models import Order, OrderItem

app = create_app()

with app.app_context():
    # Create all tables
    print("Creating order database tables...")
    db.create_all()
    print("Order database tables created successfully!")
    print("Tables: order, order_item")
