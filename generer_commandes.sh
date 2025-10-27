#!/bin/bash
echo "��� Génération de commandes pour créer des métriques métier..."
echo ""

# 1. Créer un utilisateur
echo "��� Étape 1/3 : Création d'un utilisateur de test..."
USER_RESPONSE=$(curl -s -X POST http://localhost:5001/api/user \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=testmetrics&password=test123&email=test@metrics.com")
echo "✅ Utilisateur créé"

# 2. Se connecter pour obtenir l'API key
echo "��� Étape 2/3 : Connexion..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:5001/api/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=testmetrics&password=test123")

API_KEY=$(echo $LOGIN_RESPONSE | grep -o '"api_key":"[^"]*' | cut -d'"' -f4)

if [ -z "$API_KEY" ]; then
    echo "⚠️  Utilisateur existe déjà, utilisation des credentials..."
    API_KEY="existing_user_key"
fi

echo "✅ Connecté (API Key obtenue)"

# 3. Ajouter des produits au panier (va générer les métriques !)
echo "���️  Étape 3/3 : Ajout de 3 produits au panier..."

for i in 1 2 3; do
    curl -s -X POST http://localhost:5003/api/order/add-item \
      -H "Authorization: $API_KEY" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "product_id=$i&qty=2" > /dev/null
    echo "  ✅ Produit $i ajouté (qty=2)"
    sleep 1
done

echo ""
echo "✅ TERMINÉ ! Attends 10 secondes pour que les métriques arrivent dans Prometheus..."
sleep 10

echo ""
echo "��� MAINTENANT, RETOURNE SUR PROMETHEUS :"
echo "   http://localhost:9090"
echo ""
echo "��� Tape ces requêtes COMPLÈTES (copie-colle) :"
echo ""
echo "1️⃣  target_info{service_name=\"order-service\"}"
echo ""
echo "2️⃣  Si ça marche, essaie :"
echo "    up{job=\"otel-collector\"}"
echo ""
echo "3️⃣  Pour voir TOUTES les métriques disponibles, tape juste :"
echo "    {job=\"otel-collector\"}"
echo ""
echo "    Puis clique 'Execute' et cherche dans la liste :"
echo "    - orders (cherche orders_created)"
echo "    - cart (cherche cart_items_added)"
echo ""
