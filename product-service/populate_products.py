# product-service/populate_products.py
import sys
from application import create_app, db
from application.models import Product

def populate_db():
    app = create_app()
    with app.app_context():
        # Check if products already exist
        if Product.query.first() is not None:
            print("Products already exist. Skipping population.")
            return

        print("Creating sample products...")
        
        products_to_add = [
            Product(name='Laptop Pro', slug='laptop-pro', price=1200, image='images/laptop.jpg'),
            Product(name='Smartphone X', slug='smartphone-x', price=800, image='images/smartphone.jpg'),
            Product(name='Wireless Headphones', slug='wireless-headphones', price=150, image='images/headphones.jpg'),
            Product(name='Gaming Mouse', slug='gaming-mouse', price=75, image='images/mouse.jpg'),
            Product(name='Mechanical Keyboard', slug='mechanical-keyboard', price=120, image='images/keyboard.jpg')
        ]

        db.session.bulk_save_objects(products_to_add)
        db.session.commit()
        print("Sample products have been added to the database.")

if __name__ == '__main__':
    populate_db()
