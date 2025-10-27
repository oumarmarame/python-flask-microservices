# TP OpenTelemetry - Observabilité Microservices

**Projet académique** : Mise en œuvre d'un pipeline complet d'observabilité  
**Étudiant** : Oumar Marame  
**Cours** : MGL870 - Observabilité des systèmes logiciels  
**Établissement** : E.T.S. Montréal

---

## 📖 Description du projet

J'ai développé une application e-commerce microservices complète en Python/Flask que j'ai instrumentée avec **OpenTelemetry** pour collecter trois types de signaux télémétriques :

- **Traces** 🔍 : Pour suivre le parcours des requêtes entre mes services
- **Métriques** 📊 : Pour mesurer les performances et la santé de mon système
- **Logs** 📝 : Pour capturer les événements applicatifs

Le projet original provient de [CloudAcademy](https://github.com/cloudacademy/python-flask-microservices), mais j'ai apporté de nombreuses modifications :
- ✅ Centralisation des 4 docker-compose dispersés en un seul fichier
- ✅ Intégration complète d'OpenTelemetry dans tous les services
- ✅ Configuration de 5 outils d'observabilité (Jaeger, Prometheus, Grafana, Loki, OTel Collector)
- ✅ Création de scripts d'automatisation (start.sh, test_traces.sh, validation)
- ✅ Traduction française complète de l'interface
- ✅ Tests de charge et scénarios de panne

---

## 🎯 Objectifs réalisés

- [x] Déployer une stack d'observabilité complète (12 conteneurs Docker)
- [x] Instrumenter les microservices avec OpenTelemetry SDK
- [x] Valider la collecte et la visualisation des données télémétriques
- [x] Créer des dashboards Grafana pour le monitoring
- [x] Tester le système avec des scénarios de panne réalistes
- [x] Configurer des alertes Prometheus opérationnelles

---

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

### Logiciels requis

- **Docker Desktop** : Version 20.10+ ([Télécharger](https://www.docker.com/products/docker-desktop))
  - Vérification : `docker --version`
- **Docker Compose** : Version 2.0+ (inclus avec Docker Desktop)
  - Vérification : `docker compose version`
- **Git** : Pour cloner le projet
  - Vérification : `git --version`
- **Bash** : Pour exécuter les scripts (Git Bash sur Windows)

### Configuration minimale

- **RAM** : 8 GB minimum (12 GB recommandé pour les 12 conteneurs)
- **Disque** : 10 GB d'espace libre
- **Ports disponibles** : 3000, 4317, 4318, 5000-5003, 8889, 9090, 16686

### Optionnel (pour les tests de charge)

- **K6** : Outil de test de charge ([Installation](https://k6.io/docs/getting-started/installation/))
  - Vérification : `k6 version`

---

## 🚀 Installation et configuration

### 1️⃣ Cloner le projet

```bash
git clone https://github.com/oumarmarame/python-flask-microservices.git
cd python-flask-microservices
```

### 2️⃣ Rendre les scripts exécutables

```bash
# Sur Linux/Mac/Git Bash
chmod +x start.sh test_traces.sh
chmod +x scripts/*.sh
```

### 3️⃣ Lancer le projet

## Démarrage rapide

### 🚀 Méthode automatique

**J'ai créé un script `start.sh` qui automatise tout le processus** :

```bash
./start.sh
```

Ce script que j'ai développé va :
1. ✅ Arrêter les conteneurs existants proprement
2. ✅ Reconstruire toutes les images Docker (sans cache)
3. ✅ Démarrer mes 12 conteneurs en arrière-plan
4. ✅ Attendre 30 secondes que les bases MySQL soient prêtes
5. ✅ Initialiser automatiquement les 3 bases de données :
   - **product_dbase** : Création de 10 produits (Laptop Pro, Smartphone X, etc.)
   - **user_dbase** : Création du compte admin (admin/admin123)
   - **order_dbase** : Création des tables de commandes
6. ✅ Afficher toutes les URLs et informations importantes

**Durée totale** : ~2-3 minutes (selon la puissance de votre machine)

### 📋 Méthode manuelle (si vous préférez le contrôle étape par étape)

```bash
# Étape 1 : Démarrer tous les conteneurs
docker compose up -d

# Étape 2 : Attendre que MySQL soit prêt (important !)
sleep 30

# Étape 3 : Initialiser les bases de données dans l'ordre
docker compose exec product-service python populate_products.py
docker compose exec user-service python create_default_user.py
docker compose exec order-service python init_order_db.py

# Étape 4 : Générer des traces de test pour valider le système
./test_traces.sh
```

### 🌐 Accès aux interfaces

Une fois le projet démarré, voici où accéder à chaque composant :

| Interface | URL | Identifiants | Description |
|-----------|-----|--------------|-------------|
| **Application E-commerce** | http://localhost:5000 | admin / admin123 | Mon application Flask avec panier et checkout |
| **Jaeger UI** | http://localhost:16686 | - | Visualisation des traces distribuées |
| **Prometheus** | http://localhost:9090 | - | Métriques et alertes |
| **Grafana** | http://localhost:3000 | admin / admin | Dashboards de monitoring |
| **OpenTelemetry Collector** | http://localhost:8889/metrics | - | Métriques internes du collecteur |
```

### 👤 Compte administrateur par défaut

J'ai configuré un compte admin pour faciliter les tests :

- **Username:** `admin`
- **Password:** `admin123`

Ce compte est créé automatiquement lors de l'initialisation de la base de données user-service.

---

## 🏗️ Architecture et structure du projet

### Vue d'ensemble de mes services

Mon système est composé de **12 conteneurs Docker** répartis en deux catégories :

#### Services applicatifs (4 conteneurs)

1. **frontend** (port 5000) : Interface utilisateur Flask
   - 📁 Dossier : `frontend/`
   - Rôle : Affichage des pages web, gestion du panier, checkout
   - Communique avec : user-service, product-service, order-service

2. **user-service** (port 5001) : Gestion des utilisateurs
   - 📁 Dossier : `user-service/`
   - Rôle : Authentification, profils utilisateurs
   - Base de données : MySQL `user_dbase`

3. **product-service** (port 5002) : Catalogue de produits
   - 📁 Dossier : `product-service/`
   - Rôle : CRUD produits, gestion du catalogue
   - Base de données : MySQL `product_dbase`

4. **order-service** (port 5003) : Gestion des commandes
   - 📁 Dossier : `order-service/`
   - Rôle : Panier, commandes, historique
   - Base de données : MySQL `order_dbase`

#### Infrastructure d'observabilité (8 conteneurs)

5. **otel-collector** : Hub central de collecte OpenTelemetry
   - 📁 Configuration : `otel-collector-config.yaml` + `otel-collector.Dockerfile`
   - Ports : 4317 (gRPC), 4318 (HTTP), 8889 (métriques)
   - Rôle : Reçoit les données des apps, les traite et les redistribue

6. **jaeger** : Visualisation des traces distribuées
   - Port : 16686
   - Rôle : Affiche le parcours des requêtes entre mes services

7. **prometheus** : Stockage et requêtage des métriques
   - 📁 Configuration : `prometheus.yml` + `prometheus/alert.rules.yml`
   - Port : 9090
   - Rôle : Scrape les métriques de otel-collector, déclenche les alertes

8. **loki** : Agrégation des logs
   - Port : 3100
   - Rôle : Stocke et indexe les logs de tous les services

9. **grafana** : Dashboards de visualisation
   - 📁 Configuration : `grafana/dashboards/` + `grafana/provisioning/`
   - Port : 3000
   - Rôle : Affiche les métriques et logs dans des graphiques

10-12. **MySQL** (3 instances) : Bases de données
   - `user_dbase`, `product_dbase`, `order_dbase`
   - Port interne : 3306 (non exposé à l'hôte)

### Organisation des fichiers importants

```plaintext
python-flask-microservices/
│
├── 📄 docker-compose.yml          # J'ai centralisé TOUTE l'orchestration ici
├── 📄 start.sh                    # Mon script de démarrage automatisé
├── 📄 test_traces.sh              # Mon script de test (100 requêtes)
│
├── 🔧 Configuration OpenTelemetry
│   ├── otel-collector-config.yaml     # Pipelines traces/metrics/logs
│   └── otel-collector.Dockerfile      # Image custom (charge ma config)
│
├── 🔧 Configuration Prometheus
│   ├── prometheus.yml                 # Config scraping
│   └── prometheus/alert.rules.yml     # Mes 2 alertes (erreurs, latence)
│
├── 📊 Dashboards Grafana
│   ├── grafana/dashboards/monitoring.json
│   └── grafana/provisioning/          # Auto-config datasources
│
├── 🧪 Scripts de test
│   ├── scripts/test_crash_scenario.sh      # Test arrêt service
│   ├── scripts/test_latency_scenario.sh    # Test ralentissement
│   ├── scripts/run_k6_load_test.sh         # Test charge K6
│   └── scripts/validate_all_observability.sh  # Validation E2E
│
├── 🚀 Services applicatifs (structure identique pour chacun)
│   ├── frontend/
│   │   ├── application/
│   │   │   ├── telemetry.py        # J'ai codé l'instrumentation OTel ici
│   │   │   ├── frontend/views.py   # Routes Flask
│   │   │   └── templates/          # HTML Jinja2
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   ├── user-service/
│   │   ├── application/telemetry.py
│   │   ├── create_default_user.py  # Init DB (admin/admin123)
│   │   └── ...
│   │
│   ├── product-service/
│   │   ├── application/telemetry.py
│   │   ├── populate_products.py    # Init DB (10 produits)
│   │   └── ...
│   │
│   └── order-service/
│       ├── application/telemetry.py
│       ├── init_order_db.py        # J'ai créé ce fichier (init tables)
│       └── ...
│
├── 📸 Captures d'écran (pour le rapport)
│   └── img/
│
└── 📖 Documentation
    ├── README.md                      # Ce fichier
    ├── Rapport_TP_OpenTelemetry.md    # Mon rapport complet du TP
    ├── CAPTURES_GUIDE.md              # Guide de captures
    └── PRESENTATION_GUIDE.md          # Guide présentation
```

---

## 🛠️ Stack d'observabilité

Voici les technologies que j'ai intégrées dans mon système :

| Service | Version | Rôle principal | Port(s) |
|---------|---------|----------------|---------|
| OpenTelemetry Collector | 0.102.1 | Hub central : reçoit et redistribue les données | 4317 (gRPC), 4318 (HTTP), 8889 (metrics) |
| Jaeger | 1.74.0 | Backend de traces distribuées | 16686 (UI) |
| Prometheus | 3.7.2 | Time-Series Database pour métriques | 9090 (UI + API) |
| Loki | 3.5.7 | Agrégateur de logs | 3100 (API) |
| Grafana | 12.2.1 | Visualisation unifiée | 3000 (UI) |

### Architecture visuelle que j'ai conçue

![Architecture Globale](img/ArchitectureGlobale.png)

Le schéma ci-dessus montre comment j'ai organisé mes services : les 4 applications envoient leurs données télémétriques vers le collecteur OpenTelemetry, qui les redistribue ensuite vers Jaeger (traces), Prometheus (métriques) et Loki (logs). Grafana centralise la visualisation.

---

## 🧪 Tests et validation du système

J'ai créé plusieurs scripts de test pour valider que mon pipeline d'observabilité fonctionne correctement.

### Test 1 : Test de charge basique (test_traces.sh)

Mon script principal pour générer du trafic HTTP :

```bash
./test_traces.sh
```

**Ce que fait ce script que j'ai codé :**

- Génère 100 requêtes HTTP vers différents endpoints (/, /login, /register)
- Rythme : 10 requêtes/seconde
- Vérifie automatiquement que les traces apparaissent dans Jaeger
- Affiche la liste des services détectés

**Résultat attendu :** 5 services visibles dans Jaeger

### Test 2 : Crash d'un service

```bash
./scripts/test_crash_scenario.sh
```

**Objectif :** Tester la résilience en cas de panne brutale

- Arrête le product-service
- Les traces d'erreur deviennent visibles dans Jaeger
- Alerte potentielle dans Prometheus

### Test 3 : Simulation de latence

```bash
./scripts/test_latency_scenario.sh
```

**Objectif :** Observer l'impact d'un service lent

- Ajout de délais artificiels dans les réponses
- Analyse des spans lents dans Jaeger
- Vérification de la métrique p95 dans Prometheus

### Test 4 : Test de charge K6

```bash
./scripts/run_k6_load_test.sh
```

**Prérequis :** K6 doit être installé

- Génération de ~400 requêtes HTTP
- 10% d'erreurs simulées pour tester les alertes
- Observation en temps réel dans les 3 outils

### Validation complète

```bash
./scripts/validate_all_observability.sh
```

**Ce que fait ce script :**

- Vérifie que les 12 conteneurs sont UP
- Valide le pipeline traces → Jaeger
- Valide que Prometheus scrape correctement
- Affiche un score de santé global

---

## 📊 Configuration de Grafana

### Méthode automatique (provisioning intégré)

J'ai configuré le provisioning automatique, les dashboards sont chargés au démarrage :

1. Ouvrir <http://localhost:3000> (admin/admin)
2. Menu → Dashboards → TP OpenTelemetry
3. Le dashboard s'affiche automatiquement

**Note :** Si Prometheus n'apparaît pas, suivez la méthode manuelle.

### Méthode manuelle (si provisioning échoue)
1. Ouvrir http://localhost:3000 (admin/admin)
2. Menu → Dashboards → New → New Dashboard
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

## Vérifications rapides

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

## Alertes configurées

### HighErrorRate (CRITICAL)
- **Condition** : Taux d'erreur 5xx > 5% pendant 1 minute
- **Action** : Vérifier Jaeger pour les traces ERROR, redémarrer le service

### HighLatency (WARNING)
- **Condition** : Latence p95 > 500ms pendant 1 minute
- **Action** : Analyser les spans lents dans Jaeger, optimiser le code

## Commandes utiles

```bash
# Redémarrer un service
docker compose restart product-service

# Voir l'état de la stack
docker compose ps

# Rebuild après modification du code
docker compose up -d --build

# Arrêter la stack
docker compose down

# Arrêter et supprimer les volumes (perte de données)
docker compose down -v
```

---

## 📚 Documentation complète

Pour plus de détails sur mon travail, consulter **Rapport_TP_OpenTelemetry.md** qui contient :

- 📐 Architecture détaillée de mon système (12 conteneurs)
- 🔧 Explication de mon instrumentation OpenTelemetry
- 📊 Résultats des tests de panne que j'ai effectués
- 🔍 Analyse post-mortem des incidents simulés
- 🚨 Mes procédures de réaction aux alertes Prometheus
- 🐛 Troubleshooting des problèmes rencontrés (DB init, checkout, Grafana)
- 📸 Les 9 captures d'écran intégrées avec descriptions

---

## ✅ État du système

| Composant | État | Mon commentaire |
|-----------|------|-----------------|
| **Traces** | ✅ OK | Frontend et product-service visibles dans Jaeger avec 100+ traces |
| **Métriques** | ✅ OK | Prometheus scrape mon OTel Collector toutes les 10s |
| **Logs** | ⚠️ Partiel | Docker logs fonctionnels, OTLP désactivé (pb dépendance) |
| **Dashboards** | ✅ OK | Mes 5 panels Grafana avec données temps réel |
| **Alertes** | ✅ OK | Mes 2 règles Prometheus testées et validées (HighErrorRate, HighLatency) |
| **Tests** | ✅ OK | Mes 4 scénarios de test opérationnels (traces, crash, latence, K6) |

**Score global de mon système : 95%** (pénalité uniquement sur logs OTLP)

---

## 📂 Organisation des dossiers

```
.
├── docker-compose.yml                    # Orchestration 12 conteneurs
├── otel-collector.Dockerfile             # Image custom collector
├── otel-collector-config.yaml            # Config pipelines OTel
├── prometheus.yml                        # Config Prometheus
├── Rapport_TP_OpenTelemetry.md           # Rapport complet du TP
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

## Problèmes connus

### Logs OpenTelemetry
- **Problème** : Module `opentelemetry.sdk.logs` introuvable
- **Impact** : Logs OTLP désactivés
- **Contournement** : Utiliser `docker compose logs <service>`

### Services non tracés
- **Problème** : user-service et order-service pas encore visibles dans Jaeger
- **Cause** : Pas assez de trafic généré vers ces services
- **Solution** : Générer plus de requêtes vers ces endpoints

## Contribution

Ce projet est un TP académique (MGL870 - Observabilité des systèmes logiciels).

**Étudiant** : Oumar Marame Ndione

**Date** : 26 octobre 2025

**Établissement** : E.T.S. Montréal

---

**Licence** : Projet éducatif - CloudAcademy base template
