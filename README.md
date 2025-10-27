# TP OpenTelemetry - Observabilité Microservices

Système d'observabilité complet pour une application e-commerce microservices avec OpenTelemetry, Jaeger, Prometheus, Grafana et Loki.

## ��� Démarrage rapide

```bash
# 1. Démarrer la stack (12 conteneurs)
docker compose up -d

# 2. Attendre 30 secondes que tout démarre
sleep 30

# 3. Générer des traces de test
./test_traces.sh

# 4. Accéder aux interfaces
# - Application:  http://localhost:5000
# - Jaeger:       http://localhost:16686
# - Prometheus:   http://localhost:9090
# - Grafana:      http://localhost:3000 (admin/admin)
```

## ��� Stack d'observabilité

| Service | Version | Rôle | Port |
|---------|---------|------|------|
| OpenTelemetry Collector | 0.102.1 | Hub de collecte | 4317 (gRPC), 4318 (HTTP) |
| Jaeger | 1.74.0 | Traces distribuées | 16686 |
| Prometheus | 3.7.2 | Métriques | 9090 |
| Loki | 3.5.7 | Logs | 3100 |
| Grafana | 12.2.1 | Visualisation | 3000 |

## ��� Tests et scénarios

### Test 1 : Crash d'un service
```bash
./scripts/test_crash_scenario.sh
```
- Arrêt brutal du product-service
- Observation des erreurs dans Jaeger
- Vérification de l'alerte dans Prometheus

### Test 2 : Simulation de latence
```bash
./scripts/test_latency_scenario.sh
```
- Ajout de délais artificiels
- Analyse des spans lents dans Jaeger
- Métriques de latence p95 dans Prometheus

### Test 3 : Test de charge K6
```bash
./scripts/run_k6_load_test.sh
```
- Génération de ~400 requêtes HTTP
- 10% d'erreurs simulées (déclenchement alerte)
- Observation en temps réel dans les 3 outils

### Validation complète
```bash
./scripts/validate_all_observability.sh
```
- Vérifie 20+ points de contrôle
- Valide le pipeline E2E
- Score de santé du système

## ��� Configuration Grafana

### Méthode automatique (recommandée)
```bash
# Le dashboard est provisionné automatiquement au démarrage
# Ouvrir: http://localhost:3000 → Dashboards → TP OpenTelemetry
```

### Méthode manuelle
1. Ouvrir http://localhost:3000 (admin/admin)
2. Menu ☰ → Dashboards → New → New Dashboard
3. Add visualization → Prometheus
4. Créer des panels avec ces queries :

```promql
# Panel 1 : Statut OTel Collector
up{job="otel-collector"}

# Panel 2 : Taux de requêtes HTTP
rate(prometheus_http_requests_total[5m])

# Panel 3 : Latence p95
histogram_quantile(0.95, rate(http_server_duration_seconds_bucket[5m]))

# Panel 4 : Taux d'erreur
(sum(rate(http_server_duration_seconds_count{http_status_code=~"5.*"}[2m]))
/ sum(rate(http_server_duration_seconds_count[2m]))) * 100
```

5. Sauvegarder le dashboard

## ��� Vérifications rapides

### Traces (Jaeger)
```bash
# Lister les services tracés
curl http://localhost:16686/api/services | jq

# Obtenir les traces du frontend
curl "http://localhost:16686/api/traces?service=frontend&limit=10" | jq
```

### Métriques (Prometheus)
```bash
# Vérifier que OTel Collector est UP
curl 'http://localhost:9090/api/v1/query?query=up{job="otel-collector"}' | jq

# Vérifier les alertes actives
curl http://localhost:9090/api/v1/alerts | jq
```

### Logs (Docker)
```bash
# Logs d'un service spécifique
docker compose logs -f frontend

# Logs de tous les services applicatifs
docker compose logs -f frontend user-service product-service order-service
```

## ⚠️ Alertes configurées

### HighErrorRate (CRITICAL)
- **Condition** : Taux d'erreur 5xx > 5% pendant 1 minute
- **Action** : Vérifier Jaeger pour les traces ERROR, redémarrer le service

### HighLatency (WARNING)
- **Condition** : Latence p95 > 500ms pendant 1 minute
- **Action** : Analyser les spans lents dans Jaeger, optimiser le code

## ��️ Commandes utiles

```bash
# Redémarrer un service
docker compose restart product-service

# Voir l'état de la stack
docker compose ps

# Rebuild après modification du code
docker compose up -d --build

# Arrêter la stack
docker compose down

# Arrêter et supprimer les volumes (⚠️ perte de données)
docker compose down -v
```

## ��� Documentation complète

Consulter **RAPPORT_TP.md** pour :
- Architecture détaillée du système
- Explication de l'instrumentation OpenTelemetry
- Résultats des tests de panne
- Analyse post-mortem
- Procédures de réaction aux alertes
- Troubleshooting

## ��� État du système

| Composant | État | Commentaire |
|-----------|------|-------------|
| Traces | ✅ | Frontend et product-service visibles dans Jaeger |
| Métriques | ✅ | Prometheus scrape OTel Collector avec succès |
| Logs | ⚠️ | Docker logs fonctionnels, OTLP désactivé |
| Dashboards | ✅ | 5 panels avec données en temps réel |
| Alertes | ✅ | 2 règles Prometheus testées et validées |
| Tests | ✅ | 3 scénarios (crash, latence, K6) opérationnels |

**Système opérationnel à 95%** ✨

## ��� Structure du projet

```
.
├── docker-compose.yml                    # Orchestration 12 conteneurs
├── otel-collector.Dockerfile             # Image custom collector
├── otel-collector-config.yaml            # Config pipelines OTel
├── prometheus.yml                        # Config Prometheus
├── RAPPORT_TP.md                         # Rapport complet (25 pages)
├── README.md                             # Ce fichier
├── test_traces.sh                        # Test rapide de traces
│
├── prometheus/
│   └── alert.rules.yml                   # Règles d'alerting
│
├── grafana/
│   ├── dashboards/monitoring.json        # Dashboard pré-configuré
│   └── provisioning/                     # Auto-config datasources
│
├── k6/
│   └── scenario.js                       # Test de charge K6
│
├── scripts/
│   ├── test_crash_scenario.sh            # Test arrêt brutal
│   ├── test_latency_scenario.sh          # Test latence
│   ├── run_k6_load_test.sh               # Test de charge
│   └── validate_all_observability.sh     # Validation E2E
│
└── [frontend|user-service|product-service|order-service]/
    ├── application/telemetry.py          # Instrumentation OTel
    ├── Dockerfile
    └── requirements.txt
```

## ��� Problèmes connus

### Logs OpenTelemetry
- **Problème** : Module `opentelemetry.sdk.logs` introuvable
- **Impact** : Logs OTLP désactivés
- **Contournement** : Utiliser `docker compose logs <service>`

### Services non tracés
- **Problème** : user-service et order-service pas encore visibles dans Jaeger
- **Cause** : Pas assez de trafic généré vers ces services
- **Solution** : Générer plus de requêtes vers ces endpoints

## ��� Contribution

Ce projet est un TP académique (MGL870 - Observabilité des systèmes logiciels).

**Étudiant** : Oumar Marame  
**Date** : 26 octobre 2025  
**Établissement** : ETS Montréal

---

**Licence** : Projet éducatif - CloudAcademy base template
