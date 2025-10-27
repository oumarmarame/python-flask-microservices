# application/frontend/views.py
import requests
from . import forms
from . import frontend_blueprint
from .. import login_manager
from .api.UserClient import UserClient
from .api.ProductClient import ProductClient
from .api.OrderClient import OrderClient
from flask import render_template, session, redirect, url_for, flash, request, current_app

from flask_login import current_user


@login_manager.user_loader
def load_user(user_id):
    return None


@frontend_blueprint.route('/', methods=['GET'])
def home():
    if current_user.is_authenticated:
        session['order'] = OrderClient.get_order_from_session()

    try:
        products = ProductClient.get_products()
    except requests.exceptions.ConnectionError:
        products = {
            'results': []
        }

    return render_template('home/index.html', products=products)


@frontend_blueprint.route('/register', methods=['GET', 'POST'])
def register():
    form = forms.RegistrationForm(request.form)
    if request.method == "POST":
        if form.validate_on_submit():
            username = form.username.data

            # Search for existing user
            user = UserClient.does_exist(username)
            if user:
                # Existing user found
                flash('Veuillez essayer un autre nom d\'utilisateur', 'error')
                return render_template('register/index.html', form=form)
            else:
                # Attempt to create new user
                user = UserClient.post_user_create(form)
                if user:
                    flash('Merci pour votre inscription, veuillez vous connecter', 'success')
                    return redirect(url_for('frontend.login'))

        else:
            flash('Erreurs détectées', 'error')

    return render_template('register/index.html', form=form)


@frontend_blueprint.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('frontend.home'))
    form = forms.LoginForm()
    if request.method == "POST":
        if form.validate_on_submit():
            api_key = UserClient.post_login(form)
            if api_key:
                session['user_api_key'] = api_key
                user = UserClient.get_user()
                session['user'] = user['result']

                order = OrderClient.get_order()
                if order.get('result', False):
                    session['order'] = order['result']

                flash('Bienvenue, ' + user['result']['username'], 'success')
                return redirect(url_for('frontend.home'))
            else:
                flash('Impossible de se connecter', 'error')
        else:
            flash('Erreurs détectées', 'error')
    return render_template('login/index.html', form=form)


@frontend_blueprint.route('/logout', methods=['GET'])
def logout():
    session.clear()
    return redirect(url_for('frontend.home'))


@frontend_blueprint.route('/product/<slug>', methods=['GET', 'POST'])
def product(slug):
    response = ProductClient.get_product(slug)
    item = response['result']

    form = forms.ItemForm(product_id=item['id'])

    if request.method == "POST":
        if 'user' not in session:
            flash('Veuillez vous connecter', 'error')
            return redirect(url_for('frontend.login'))
        order = OrderClient.post_add_to_cart(product_id=item['id'], qty=1)
        session['order'] = order['result']
        flash('Commande mise à jour', 'success')
    return render_template('product/index.html', product=item, form=form)


@frontend_blueprint.route('/checkout', methods=['GET'])
def summary():
    if 'user' not in session:
        flash('Veuillez vous connecter', 'error')
        return redirect(url_for('frontend.login'))

    if 'order' not in session:
        flash('Aucune commande trouvée', 'error')
        return redirect(url_for('frontend.home'))

    order = OrderClient.get_order()
    order_data = order.get('result', {}) if order else {}
    
    return render_template('checkout/index.html', order=order_data)


@frontend_blueprint.route('/cart/remove/<int:product_id>', methods=['POST'])
def remove_from_cart(product_id):
    if 'user' not in session:
        flash('Veuillez vous connecter', 'error')
        return redirect(url_for('frontend.login'))
    
    # Appeler l'API pour retirer le produit
    order = OrderClient.delete_item_from_cart(product_id=product_id)
    if order and order.get('result'):
        session['order'] = order['result']
        flash('Produit retiré du panier', 'success')
    else:
        flash('Erreur lors du retrait du produit', 'error')
    
    return redirect(url_for('frontend.summary'))


@frontend_blueprint.route('/checkout/process', methods=['POST'])
def process_checkout():
    if 'user' not in session:
        flash('Veuillez vous connecter', 'error')
        return redirect(url_for('frontend.login'))

    if 'order' not in session:
        flash('Aucune commande trouvée', 'error')
        return redirect(url_for('frontend.home'))

    OrderClient.post_checkout()

    return redirect(url_for('frontend.thank_you'))

@frontend_blueprint.route('/order/thank-you', methods=['GET'])
def thank_you():
    if 'user' not in session:
        flash('Veuillez vous connecter', 'error')
        return redirect(url_for('frontend.login'))

    if 'order' not in session:
        flash('Aucune commande trouvée', 'error')
        return redirect(url_for('frontend.home'))

    session.pop('order', None)
    flash('Merci pour votre commande', 'success')

    return render_template('order/thankyou.html')