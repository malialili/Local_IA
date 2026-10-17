# Local_IA

Projet pour exécuter des modèles de langage (LLM) localement avec **Ollama** et une interface graphique **Open WebUI**.

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
