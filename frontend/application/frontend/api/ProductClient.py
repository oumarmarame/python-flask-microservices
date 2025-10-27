# application/frontend/api/ProductClient.py
import requests


class ProductClient:

    @staticmethod
    def get_products():
        r = requests.get('http://product-service:5000/api/products')
        products = r.json()
        return products

    @staticmethod
    def get_product(slug):
        response = requests.request(method="GET", url='http://product-service:5000/api/product/' + slug)
        product = response.json()
        return product
