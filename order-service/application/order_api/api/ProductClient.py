# application/order_api/api/ProductClient.py
import requests
import os


class ProductClient:
    @staticmethod
    def get_product(product_id):
        """Récupère les informations d'un produit par son ID"""
        product_service_url = os.environ.get('PRODUCT_SERVICE_URL', 'http://product-service:5000')
        url = f'{product_service_url}/api/product/{product_id}'
        
        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                return response.json().get('result')
            return None
        except Exception as e:
            print(f"Error fetching product {product_id}: {e}")
            return None
