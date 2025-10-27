// k6/scenario.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

// Métrique K6 personnalisée pour suivre le temps de réponse de la création de commande
const orderCreationTime = new Trend('order_creation_time');

export const options = {
  stages: [
    // Monte en charge doucement jusqu'à 10 utilisateurs virtuels
    { duration: '30s', target: 10 },
    // Reste à 10 utilisateurs virtuels pendant 1 minute (charge normale)
    { duration: '1m', target: 10 },
    // Simule un pic de charge pour tester l'alerte de latence
    { duration: '30s', target: 20 },
    // Redescend
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    // Le TP demande de réagir aux pannes. On vérifie que nos erreurs 5xx restent faibles.
    'http_req_failed{status>=500}': ['rate<0.05'], // Moins de 5% des requêtes doivent être des erreurs 5xx
    'order_creation_time': ['p(95)<800'], // 95% des créations de commande en moins de 800ms
  },
};

// L'URL de base de notre application
const BASE_URL = 'http://localhost:5000';

export default function () {
  // 1. Visite la page d'accueil (charge simple)
  http.get(BASE_URL);
  sleep(1);

  // 2. 90% du temps, simule une commande VALIDE
  if (Math.random() < 0.9) {
    const orderPayload = JSON.stringify({
      user_id: 1, // On suppose que l'utilisateur 1 existe (à créer manuellement au premier lancement)
      product_id: 1, // On suppose que le produit 1 existe
    });
    const orderParams = {
      headers: { 'Content-Type': 'application/json' },
    };
    
    const orderRes = http.post(`${BASE_URL}/order`, orderPayload, orderParams);
    
    // Ajoute la durée de cette requête à notre métrique de tendance
    orderCreationTime.add(orderRes.timings.duration);
    
    check(orderRes, {
      'commande valide (201)': (r) => r.status === 201,
    });
  } 
  // 3. 10% du temps, simule une PANNE (pour déclencher l'alerte 5xx)
  // Nous envoyons du texte brut au lieu de JSON. Flask/Python lèvera une
  // exception de parsing, ce qui générera une erreur 500 (Internal Server Error).
  else {
    const badPayload = "ceci n'est pas du json";
    const orderParams = { headers: { 'Content-Type': 'text/plain' } };
    const orderRes = http.post(`${BASE_URL}/order`, badPayload, orderParams);

    check(orderRes, {
      'panne simulée (500)': (r) => r.status === 500,
    });
  }

  sleep(2);
}
