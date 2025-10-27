# application/frontend/api/OrderClient.py
from flask import session
import requests


class OrderClient:
    @staticmethod
    def get_order():
        headers = {
            'Authorization': 'Basic ' + session.get('user_api_key', '')
        }
        url = 'http://order-service:5000/api/order'
        response = requests.request(method="GET", url=url, headers=headers)
        order = response.json()
        return order

    @staticmethod
    def post_add_to_cart(product_id, qty=1):
        payload = {
            'product_id': product_id,
            'qty': qty
        }
        url = 'http://order-service:5000/api/order/add-item'

        headers = {
            'Authorization': 'Basic ' + session.get('user_api_key', '')
        }
        response = requests.request("POST", url=url, data=payload, headers=headers)
        if response:
            order = response.json()
            return order

    @staticmethod
    def delete_item_from_cart(product_id):
        url = f'http://order-service:5000/api/order/remove-item/{product_id}'

        headers = {
            'Authorization': 'Basic ' + session.get('user_api_key', '')
        }
        response = requests.request("DELETE", url=url, headers=headers)
        if response:
            order = response.json()
            return order

    @staticmethod
    def post_checkout():
        url = 'http://order-service:5000/api/order/checkout'

        headers = {
            'Authorization': 'Basic ' + session.get('user_api_key', '')
        }
        response = requests.request("POST", url=url, headers=headers)
        order = response.json()
        return order

    @staticmethod
    def get_order_from_session():
        default_order = {
            'items': {},
            'total': 0,
        }
        return session.get('order', default_order)
