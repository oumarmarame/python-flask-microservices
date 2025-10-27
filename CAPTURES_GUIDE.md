# Guide des Captures d'Écran - TP OpenTelemetry

## 📸 Captures à prendre (ordre recommandé)

### 1️⃣ JAEGER - Traces distribuées
**URL** : http://localhost:16686

**Actions** :
1. Sélectionner "frontend" dans le menu Service
2. Cliquer "Find Traces"
3. 📸 **CAPTURE** : `img/jaeger-traces-list.png` - Liste des traces
4. Cliquer sur une trace pour ouvrir les détails
5. 📸 **CAPTURE** : `img/jaeger-trace-detail.png` - Timeline des spans

**Ce qu'on voit** :
- Services instrumentés (frontend, product-service, user-service, order-service)
- Durée des requêtes
- Relations parent-enfant entre spans
- Attributs HTTP (méthode, status code, URL)

---

### 2️⃣ PROMETHEUS - Targets
**URL** : http://localhost:9090/targets

**Actions** :
1. Ouvrir la page Targets directement
2. 📸 **CAPTURE** : `img/prometheus-targets.png`

**Ce qu'on voit** :
- Target "otel-collector" avec status UP (vert)
- Endpoint : otel-collector:8889/metrics
- Last Scrape (temps de scraping)

---

### 3️⃣ PROMETHEUS - Métriques
**URL** : http://localhost:9090/graph

**Actions** :
1. Dans le champ de requête, taper : `up{job="otel-collector"}`
2. Cliquer "Execute"
3. Basculer sur l'onglet "Graph"
4. 📸 **CAPTURE** : `img/prometheus-metrics.png`

**Autres requêtes intéressantes** :
```promql
# Taux de requêtes HTTP
rate(prometheus_http_requests_total[5m])

# Latence p95
histogram_quantile(0.95, rate(http_server_duration_seconds_bucket[5m]))

# Taux d'erreur
sum(rate(http_server_duration_seconds_count{http_status_code=~"5.*"}[2m])) / sum(rate(http_server_duration_seconds_count[2m])) * 100
```

---

### 4️⃣ PROMETHEUS - Alertes
**URL** : http://localhost:9090/alerts

**Actions** :
1. Ouvrir la page Alerts
2. 📸 **CAPTURE** : `img/prometheus-alerts.png`

**Ce qu'on voit** :
- Liste des alertes configurées (HighErrorRate, HighLatency)
- État : Inactive (vert) ou Firing (rouge)
- Expression PromQL
- Annotations

---

### 5️⃣ GRAFANA - Dashboard
**URL** : http://localhost:3000 (admin/admin)

**Actions** :
1. Se connecter (admin/admin)
2. Menu gauche → Dashboards
3. Ouvrir "TP OpenTelemetry - Monitoring Stack" ou "monitoring"
4. 📸 **CAPTURE** : `img/grafana-dashboard.png`

**Si pas de dashboard** :
1. Menu gauche → Explore
2. Sélectionner "Prometheus" comme data source
3. Taper `up{job="otel-collector"}`
4. Cliquer "Run query"
5. 📸 **CAPTURE** : `img/grafana-explore.png`

---

### 6️⃣ APPLICATION - Frontend (optionnel)
**URL** : http://localhost:5000

**Actions** :
1. 📸 **CAPTURE** : `img/frontend-home.png` - Page d'accueil
2. Cliquer sur "Products"
3. 📸 **CAPTURE** : `img/frontend-products.png` - Liste produits

---

## 🚀 Commandes utiles

### Générer du trafic pour avoir des données
```bash
./test_traces.sh
```

### Test de charge K6 (génère beaucoup de données)
```bash
./scripts/run_k6_load_test.sh
```

### Vérifier que tout fonctionne
```bash
docker compose ps
```

### Voir les logs en cas de problème
```bash
docker compose logs otel-collector
docker compose logs jaeger
docker compose logs prometheus
```

---

## 📁 Organisation des captures

```
img/
├── ArchitectureGlobale.png                 ✅ Déjà présent
├── FluxdeDonnéesTélémétriques.png         ✅ Déjà présent
├── PipelineOpenTelemetry.png              ✅ Déjà présent
├── ArchitectureRéseauDocker.png           ✅ Déjà présent
├── jaeger-traces-list.png                 📸 À prendre
├── jaeger-trace-detail.png                📸 À prendre
├── prometheus-targets.png                 📸 À prendre
├── prometheus-metrics.png                 📸 À prendre
├── prometheus-alerts.png                  📸 À prendre
├── grafana-dashboard.png                  📸 À prendre
├── grafana-explore.png                    📸 À prendre (optionnel)
├── frontend-home.png                      📸 À prendre (optionnel)
└── frontend-products.png                  📸 À prendre (optionnel)
```

---

## 💡 Astuces

1. **Utilisez Windows Snipping Tool** (Win + Shift + S) pour capturer rapidement
2. **Nommez les fichiers exactement comme indiqué** pour faciliter l'intégration
3. **Capturez en plein écran** pour avoir des images nettes
4. **Attendez que les graphiques soient chargés** avant de capturer
5. **Générez du trafic d'abord** avec `./test_traces.sh` pour avoir des données visibles

---

## ✅ Checklist

- [ ] Jaeger : Liste des traces
- [ ] Jaeger : Détail d'une trace
- [ ] Prometheus : Targets (otel-collector UP)
- [ ] Prometheus : Graphique de métrique
- [ ] Prometheus : Page des alertes
- [ ] Grafana : Dashboard complet
- [ ] Grafana : Explore (si pas de dashboard)
- [ ] Frontend : Page d'accueil (optionnel)
- [ ] Frontend : Page produits (optionnel)

**Total minimum** : 6 captures obligatoires
**Total recommandé** : 9 captures (avec frontend)
