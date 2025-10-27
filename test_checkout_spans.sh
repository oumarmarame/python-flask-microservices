#!/bin/bash
echo "�� Génération de trafic pour tester les spans personnalisés..."
echo ""

# Faire 5 requêtes sur la page checkout (va générer des spans enrichis)
for i in {1..5}; do
    echo "Requête $i/5..."
    curl -s http://localhost:5000/checkout > /dev/null 2>&1
    sleep 1
done

echo ""
echo "✅ Trafic généré ! Attends 5 secondes pour l'exportation vers Jaeger..."
sleep 5
echo ""
echo "��� MAINTENANT :"
echo "1. Ouvre ton navigateur : http://localhost:16686"
echo "2. Service : Sélectionne 'frontend'"
echo "3. Operation : Sélectionne 'GET /checkout'"
echo "4. Clique sur 'Find Traces'"
echo "5. Clique sur une trace (ligne bleue)"
echo "6. Cherche le span 'checkout_validation' (en orange/jaune)"
echo "7. Clique dessus pour voir les ATTRIBUTS enrichis :"
echo "   - checkout.status"
echo "   - order.id" 
echo "   - order.items_count"
echo "   - order.total_price"
echo "   - user.id"
echo ""
