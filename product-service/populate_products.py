# product-service/populate_products.py
import sys
from application import create_app, db
from application.models import Product

def populate_db():
    app = create_app()
    with app.app_context():
        # Create all tables first
        db.create_all()
        
        # Delete all existing products
        print("Deleting existing products...")
        Product.query.delete()
        db.session.commit()

        print("Creating sample products...")
        
        products_to_add = [
            Product(name='Laptop Pro', slug='laptop-pro', price=1200, image='laptop.jpg'),
            Product(name='Smartphone X', slug='smartphone-x', price=800, image='smartphone.jpg'),
            Product(name='Casque Sans Fil', slug='wireless-headphones', price=150, image='headphones.jpg'),
            Product(name='Souris Gaming', slug='gaming-mouse', price=75, image='mouse.jpg'),
            Product(name='Clavier Mécanique', slug='mechanical-keyboard', price=120, image='keyboard.jpg'),
            Product(name='Écran 4K', slug='4k-monitor', price=450, image='monitor.jpg'),
            Product(name='Webcam HD', slug='webcam-hd', price=90, image='webcam.jpg'),
            Product(name='Hub USB-C', slug='usb-c-hub', price=45, image='hub.jpg'),
            Product(name='Chargeur Sans Fil', slug='wireless-charger', price=35, image='charger.jpg'),
            Product(name='SSD Externe 1TB', slug='external-ssd', price=150, image='ssd.jpg')
        ]

        db.session.bulk_save_objects(products_to_add)
        db.session.commit()
        print("Sample products have been added to the database.")

if __name__ == '__main__':
    populate_db()
