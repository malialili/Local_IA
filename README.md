# Local_IA

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://docker.com)
[![Ollama](https://img.shields.io/badge/Ollama-Supported-green?logo=ollama)](https://ollama.ai)
[![Open WebUI](https://img.shields.io/badge/Open_WebUI-Latest-orange)](https://openwebui.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Stars](https://img.shields.io/github/stars/malialili/Local_IA?style=social)](https://github.com/malialili/Local_IA)
[![Issues](https://img.shields.io/github/issues/malialili/Local_IA)](https://github.com/malialili/Local_IA/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/malialili/Local_IA)](https://github.com/malialili/Local_IA/pulls)

**Projet pour exécuter des modèles de langage (LLM) localement avec une interface graphique complète.**

---

## 🌟 **Nouveautés**

✨ **Dernières améliorations :**
- 📁 **Structure de projet organisée** avec dossiers dédiés (`docker/`, `scripts/`, `configs/`, `docs/`)
- 🐳 **4 configurations Docker Compose** : base, GPU, CPU, multi-backend, monitoring
- 📜 **5 scripts de maintenance** : pull_models, cleanup, backup, restore, update, monitor
- 📊 **Documentation complète** : benchmarks, troubleshooting, configuration avancée
- 🎨 **Monitoring intégré** avec Prometheus + Grafana + tableau de bord pré-configuré
- 🔧 **Pré-téléchargement automatique** des modèles au démarrage

---

## 📂 **Structure du Projet**

```
Local_IA/
├── docker/
│   ├── compose/
│   │   ├── base.yml          # Configuration de base (Ollama + Open WebUI)
│   │   ├── gpu.yml           # Optimisé pour GPU NVIDIA
│   │   ├── cpu.yml           # Optimisé pour CPU seulement
│   │   ├── preload.yml       # Avec pré-téléchargement des modèles
│   │   ├── with-models.yml   # Image Docker avec modèles intégrés
│   │   ├── multi.yml         # Multi-backend (Ollama + LocalAI)
│   │   └── monitoring.yml    # Monitoring complet (Prometheus + Grafana)
│   └── Dockerfile.ollama     # Pour construire une image avec modèles
├── scripts/
│   ├── pull_models.sh        # Télécharger des modèles
│   ├── cleanup.sh            # Nettoyer les modèles inutilisés
│   ├── backup.sh             # Sauvegarder les données
│   ├── restore.sh            # Restaurer une sauvegarde
│   ├── update.sh             # Mettre à jour Ollama + Open WebUI
│   └── monitor.sh            # Monitorer l'utilisation des ressources
├── configs/
│   ├── .env.example          # Configuration par défaut
│   └── openwebui/            # Configurations Open WebUI
├── monitoring/
│   ├── prometheus.yml        # Configuration Prometheus
│   └── grafana/              # Configuration Grafana + dashboards
├── docs/
│   ├── benchmarks.md         # Comparaison détaillée des modèles
│   └── (autres docs)         # Documentation supplémentaire
├── .gitignore
├── LICENSE
└── README.md
```

---

## 🚀 **Démarrage Rapide**

### Option 1: Configuration de base (recommandée)
```bash
git clone https://github.com/malialili/Local_IA.git
cd Local_IA

# Copier la configuration
cp configs/.env.example .env

# Démarrer les services
docker compose -f docker/compose/base.yml up -d

# Accéder à l'interface
# http://localhost:8080
```

### Option 2: Avec GPU NVIDIA
```bash
docker compose -f docker/compose/gpu.yml up -d
```

### Option 3: Avec pré-téléchargement des modèles
```bash
# Modifier la liste des modèles dans docker/compose/preload.yml
docker compose -f docker/compose/preload.yml up -d
```

### Option 4: Avec monitoring complet
```bash
docker compose -f docker/compose/monitoring.yml up -d
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
```

---

## 🎯 **Commandes Utiles**

| Commande | Description |
|----------|-------------|
| `docker compose -f docker/compose/base.yml up -d` | Démarrer les services de base |
| `docker compose -f docker/compose/base.yml down` | Arrêter les services |
| `docker compose -f docker/compose/base.yml logs -f` | Voir les logs en temps réel |
| `./scripts/pull_models.sh llama3.2:3b mistral:7b` | Télécharger des modèles |
| `./scripts/pull_models.sh --all` | Télécharger tous les modèles recommandés |
| `./scripts/cleanup.sh --dry-run` | Voir quels modèles seraient supprimés |
| `./scripts/cleanup.sh --keep llama3.2:3b` | Nettoyer en gardant certains modèles |
| `./scripts/backup.sh ./backups/` | Sauvegarder les données |
| `./scripts/restore.sh ./backups/backup.tar.gz` | Restaurer une sauvegarde |
| `./scripts/update.sh` | Mettre à jour Ollama et Open WebUI |
| `./scripts/monitor.sh` | Monitorer l'utilisation des ressources |
| `./scripts/monitor.sh --continuous` | Monitoring en continu |

---

## 📚 **Documentation**

- [📊 **Benchmarks des Modèles**](docs/benchmarks.md) - Comparaison détaillée des performances
- [🏗️ **Architecture**](#-architecture-ollama-vs-open-webui) - Explication Ollama vs Open WebUI
- [🎨 **Configuration Avancée**](#-configuration-avancée) - Personnalisation et optimisation

---

## 🤝 **Contribuer**

Les contributions sont les bienvenues !

1. Fork le projet
2. Créez une branche (`git checkout -b feature/ma-fonctionnalité`)
3. Committez vos changements (`git commit -m 'Ajout de ma fonctionnalité'`)
4. Poussez vers la branche (`git push origin feature/ma-fonctionnalité`)
5. Ouvrez une Pull Request

---

## 📜 **Licence**

Ce projet est sous licence **MIT** - voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 🙏 **Remerciements**

- [Ollama](https://ollama.ai) - Pour le moteur LLM local
- [Open WebUI](https://openwebui.com) - Pour l'interface graphique
- [Docker](https://docker.com) - Pour la conteneurisation
- Tous les contributeurs open-source qui rendent ce projet possible !

---



## 🏗️ Architecture : Ollama vs Open WebUI

### 🎯 **Différence fondamentale**

**Ollama** et **Open WebUI** sont **complémentaires** mais ont des rôles distincts :

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│   👤 VOUS       │────▶│   Open WebUI    │────▶│     Ollama      │
│   (Navigateur)  │     │   (Frontend)     │     │   (Backend)     │
│                 │     │   Port: 8080     │     │   Port: 11434   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
       │                        │                        │
       │                        ▼                        ▼
       │                ┌─────────────────────────────────┐
       │                │  Réseau Docker (llm_network)     │
       │                └─────────────────────────────────┘
       │                        │
       ▼                        │
┌─────────────────┐             │
│  💬 Interface    │◀────────────┘
│  📝 Conversations│
│  ⚙️  Paramètres  │
└─────────────────┘
```

### 🔧 **Ollama : Le Moteur (Backend)**

| **Fonction** | **Description** |
|--------------|----------------|
| 🧠 **Exécution des modèles** | Lance Llama, Mistral, Phi, Gemma, etc. sur votre machine |
| 💾 **Gestion des modèles** | Télécharge, stocke et met à jour les fichiers de modèles |
| 🌐 **API REST** | Fournit une interface sur `http://localhost:11434` |
| ⚡ **Optimisation** | Gère la mémoire, le GPU, la quantisation (4-bit par défaut) |
| 📊 **Inférence** | Traite les requêtes et génère les réponses |

**Exemple d'utilisation directe (sans Open WebUI) :**
```bash
# Demander une réponse via l'API Ollama
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Explique la photosynthèse simplement",
  "stream": false
}'
```

### 🎨 **Open WebUI : L'Interface (Frontend)**

| **Fonction** | **Description** |
|--------------|----------------|
| 🖥️ **Interface Web** | Belle UI accessible sur `http://localhost:8080` |
| 💬 **Gestion des conversations** | Historique, organisation, partage des chats |
| ⚙️ **Configuration visuelle** | Changer de modèle et paramètres sans CLI |
| 🔌 **Multi-backend** | Peut se connecter à Ollama, LocalAI, LM Studio, etc. |
| 🎨 **Expérience utilisateur** | Thèmes, plugins, personnalisation |

**À quoi ça ressemble :**
> Une interface moderne type ChatGPT, avec sélection de modèle, historique des conversations, et paramètres avancés.

### 🔄 **Comment ils communiquent ?**

1. **Vous** envoyez une requête via Open WebUI (navigateur)
2. **Open WebUI** transmet la requête à Ollama via l'API (`http://ollama:11434`)
3. **Ollama** exécute le modèle et génère la réponse
4. **Ollama** renvoie la réponse à Open WebUI
5. **Open WebUI** affiche la réponse dans votre navigateur

### 📊 **Tableau comparatif**

| **Critère** | **Ollama** | **Open WebUI** |
|------------|-----------|----------------|
| **Rôle** | Moteur LLM (Backend) | Interface graphique (Frontend) |
| **Port** | 11434 | 8080 |
| **Nécéssaire pour faire tourner les modèles ?** | ✅ Oui | ❌ Non |
| **Nécéssaire pour une interface graphique ?** | ❌ Non | ✅ Oui |
| **Gère les modèles** | ✅ Oui | ❌ Non |
| **Stocke les conversations** | ❌ Non | ✅ Oui |
| **Type d'utilisation** | API (code, scripts) | Navigateur web |
| **Alternatives** | LocalAI, LM Studio, vLLM | Text Generation WebUI, etc. |

### 💡 **Peut-on utiliser Ollama sans Open WebUI ?**
✅ **OUI** - Via l'API directe, des scripts Python, ou en ligne de commande :
```bash
# Utilisation basique
docker exec ollama ollama run llama3.2:3b "Explique moi l'IA"

# Avec streaming
docker exec ollama ollama run mistral:7b "Quelle est la capitale de la France ?"
```

### 💡 **Peut-on utiliser Open WebUI sans Ollama ?**
✅ **OUI** - Open WebUI peut se connecter à d'autres backends :
- LocalAI
- LM Studio
- API compatibles OpenAI
- Fournisseurs cloud (OpenAI, Anthropic, etc.)

**Configuration :**
Modifiez `OLLAMA_BASE_URL` dans `.env` pour pointer vers un autre backend.

## Prérequis

- [Docker](https://www.docker.com/) et [Docker Compose](https://docs.docker.com/compose/) installés
- (Optionnel) GPU NVIDIA pour l'accélération matérielle (recommandé pour les grands modèles)
- Au moins 8 Go de RAM (16 Go recommandés pour les modèles de 7B+)

## Installation et Lancement

### 1. Cloner le dépôt

```bash
git clone https://github.com/malialili/Local_IA.git
cd Local_IA
```

### 2. Configuration

Copiez le fichier `.env.example` en `.env` et modifiez les variables si nécessaire :

```bash
cp .env.example .env
```

Éditez le fichier `.env` pour adapter les ports ou autres paramètres.

### 3. Démarrer les services

```bash
docker compose up -d
```

Cela lancera :
- **Ollama** : Serveur pour exécuter les modèles LLMs
- **Open WebUI** : Interface graphique pour interagir avec les modèles

### 4. Accéder à l'interface

Ouvrez votre navigateur et allez sur :

```
http://localhost:8080
```

### 5. Télécharger un modèle

Via l'interface Open WebUI ou en ligne de commande :

```bash
# Exemple : télécharger Llama 3.2 3B
curl -X POST http://localhost:11434/api/pull -d '{"name": "llama3.2:3b"}'
```

## Modèles recommandés

### 🔥 Modèles Llama (Meta)
- `llama3.2:3b` - Léger, bon pour les tests (3B paramètres)
- `llama3.2:11b` - Équilibre performance/ressources (11B paramètres)
- `llama3.2:1b` - Ultra-léger pour les machines limitées
- `llama3.2:90b` - Très performant (nécessite beaucoup de RAM/GPU)

### ⚡ Modèles Mistral AI
- `mistral:7b` - Alternative performante, excellent pour le code
- `mistral-nemo:12b` - Modèle optimisé pour le raisonnement
- `mixtral:8x7b` - Modèle expert (mélange de 8 modèles 7B)

### 🧠 Modèles Microsoft Phi
- `phi3:3.8b` - Optimisé pour le raisonnement et les tâches logiques
- `phi3:14b` - Plus puissant, bon pour les tâches complexes
- `phi3.5:3.8b` - Version améliorée avec meilleur raisonnement

### 🤖 Modèles Gemma (Google)
- `gemma:2b` - Modèle léger et rapide
- `gemma:7b` - Bonne performance générale
- `gemma2:9b` - Nouvelle génération, très performant

### 📊 Modèles Code (spécialisés pour le développement)
- `codellama:7b` - Optimisé pour la génération de code
- `codegemma:7b` - Alternative pour le code
- `deepseek-coder:6.7b` - Excellente compréhension du code

### 💡 Comment choisir ?
| Besoin | Modèle recommandé | RAM requise | GPU recommandé |
|--------|------------------|-------------|----------------|
| Tests rapides | `llama3.2:3b` ou `phi3:3.8b` | 4-6 Go | Optionnel |
| Usage général | `llama3.2:11b` ou `mistral:7b` | 8-12 Go | 12 Go+ |
| Développement | `codellama:7b` ou `deepseek-coder:6.7b` | 8-10 Go | 12 Go+ |
| Raisonnement | `phi3.5:3.8b` ou `llama3.2:11b` | 8-12 Go | 12 Go+ |
| Haute performance | `llama3.2:90b` ou `mixtral:8x7b` | 48 Go+ | 48 Go+ |

### 📥 Téléchargement via l'interface
1. Ouvrez Open WebUI sur `http://localhost:8080`
2. Allez dans l'onglet **Models**
3. Cliquez sur **Pull** et sélectionnez un modèle dans la liste
4. Ou entrez manuellement le nom du modèle (ex: `gemma2:9b`)
5. Attendez la fin du téléchargement (peut prendre plusieurs minutes)

### 🚀 Téléchargement en ligne de commande

```bash
# Télécharger plusieurs modèles d'un coup
docker exec ollama ollama pull llama3.2:3b
docker exec ollama ollama pull mistral:7b
docker exec ollama ollama pull gemma2:9b

# Vérifier les modèles téléchargés
docker exec ollama ollama list
```

### 📜 Script de téléchargement automatique

Un script `scripts/pull_models.sh` est disponible pour simplifier le téléchargement :

```bash
# Rendre le script exécutable (une seule fois)
chmod +x scripts/pull_models.sh

# Télécharger des modèles spécifiques
./scripts/pull_models.sh llama3.2:3b mistral:7b

# Télécharger tous les modèles recommandés
./scripts/pull_models.sh --all

# Télécharger uniquement les modèles de code
./scripts/pull_models.sh --code

# Télécharger uniquement les modèles légers (< 5 Go)
./scripts/pull_models.sh --small

# Lister les modèles déjà téléchargés
./scripts/pull_models.sh --list

# Afficher l'aide
./scripts/pull_models.sh --help
```

### 🐳 Pré-téléchargement au démarrage

#### Option 1: Utiliser docker-compose-preload.yml (recommandé)

Ce fichier lance un conteneur d'initialisation qui télécharge les modèles **avant** de démarrer Open WebUI.

```bash
# Modifier la liste des modèles dans docker-compose-preload.yml
# (ligne: MODELS="llama3.2:3b mistral:7b phi3:3.8b")

# Démarrer avec pré-téléchargement
docker compose -f docker-compose-preload.yml up -d

# Voir les logs de l'initialisation
docker compose -f docker-compose-preload.yml logs -f ollama-init
```

**Avantages:**
- Les modèles sont prêts avant que l'interface ne soit accessible
- Pas besoin de créer une grosse image Docker
- Flexible : modifiez la liste des modèles à tout moment

#### Option 2: Créer une image Docker avec modèles intégrés

Pour les environnements où vous voulez une image autonome avec les modèles inclus.

```bash
# Modifier Dockerfile.ollama pour changer les modèles
# (ligne: ARG MODELS_TO_PRELOAD="llama3.2:3b mistral:7b")

# Construire l'image (ATTENTION: peut prendre beaucoup de temps et d'espace)
docker compose -f docker-compose-with-models.yml build

# Démarrer
docker compose -f docker-compose-with-models.yml up -d
```

**⚠️ Attention:**
- L'image résultante sera très grande (plusieurs Go)
- Le build peut prendre beaucoup de temps
- Recommandé uniquement pour les petits modèles ou les déploiements en production

#### Option 3: Utiliser un volume partagé avec modèles pré-téléchargés

1. Téléchargez les modèles manuellement sur votre machine
2. Montez le dossier local dans le conteneur

```yaml
# Dans docker-compose.yml, modifiez la section volumes de ollama:
services:
  ollama:
    volumes:
      - ./ollama_models:/root/.ollama
      # Au lieu de: - ollama_data:/root/.ollama
```

Puis placez vos modèles dans `./ollama_models` avant de démarrer.

## Commandes utiles

### Voir les logs

```bash
# Logs de tous les services
docker compose logs -f

# Logs d'Ollama uniquement
docker compose logs -f ollama

# Logs d'Open WebUI uniquement
docker compose logs -f open-webui
```

### Arrêter les services

```bash
docker compose down
```

### Mettre à jour

```bash
# Arrêter les services
docker compose down

# Tirer les dernières images
docker compose pull

# Redémarrer
docker compose up -d
```

### Gérer les modèles avec Ollama CLI

Si vous voulez utiliser la CLI Ollama directement :

```bash
# Lister les modèles disponibles
docker exec ollama ollama list

# Télécharger un modèle
docker exec ollama ollama pull llama3.2:3b

# Supprimer un modèle
docker exec ollama ollama rm llama3.2:3b

# Voir les infos d'un modèle
docker exec ollama ollama show llama3.2:3b
```

## Configuration avancée

### Changer le modèle par défaut

Dans Open WebUI, allez dans les paramètres et configurez le modèle par défaut.

### Activer l'authentification

Modifiez `.env` :
```
WEBUI_AUTH=True
```

Puis redémarrez :
```bash
docker compose down && docker compose up -d
```

### Utiliser un GPU spécifique

Éditez `docker-compose.yml` pour modifier la section `deploy.resources` sous le service `ollama`.

### Persistance des données

Les données sont stockées dans des volumes Docker :
- `ollama_data` : Contient les modèles téléchargés
- `open_webui_data` : Contient les conversations et configurations

Pour sauvegarder :
```bash
# Sauvegarder les volumes
docker run --rm -v ollama_data:/volume -v $(pwd):/backup busybox tar cvf /backup/ollama_data.tar /volume
docker run --rm -v open_webui_data:/volume -v $(pwd):/backup busybox tar cvf /backup/open_webui_data.tar /volume
```

## Résolution des problèmes

### Problème de GPU

Si vous avez une erreur liée au GPU :
1. Vérifiez que NVIDIA Container Toolkit est installé
2. Vérifiez avec `nvidia-smi` que le GPU est détecté
3. Redémarrez Docker : `sudo systemctl restart docker`

### Manque de mémoire

Pour les grands modèles, augmentez la mémoire allouée à Docker (dans les paramètres de Docker Desktop ou via `docker daemon` configuration).

### Port déjà utilisé

Modifiez les ports dans `.env` et `docker-compose.yml`, puis redémarrez.

## Contribuer

Les contributions sont les bienvenues ! Ouvrez une issue ou une pull request.

## Licence

Ce projet est sous licence MIT.
