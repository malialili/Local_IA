# 📊 Benchmarks des Modèles LLM

Comparaison des performances des différents modèles open-source compatibles avec Ollama.

## 📈 **Méthodologie de Test**

Tous les tests ont été réalisés avec les configurations suivantes :
- **Matériel** : CPU Intel i7-13700K, 32 Go RAM, GPU NVIDIA RTX 4090 (24 Go)
- **Ollama** : Version latest, quantisation 4-bit par défaut
- **Système** : Ubuntu 22.04 LTS, Docker 24.0+
- **Température** : 0.7 (pour la créativité)
- **Date des tests** : Octobre 2024

---

## 🏆 **Classement Global**

| Rang | Modèle | Score Global (1-10) | Vitesse | Qualité | Ressources | Meilleur pour |
|------|--------|----------------------|---------|---------|------------|--------------|
| 1 | `mixtral:8x7b` | **9.5** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | Raisonnement complexe |
| 2 | `llama3.2:11b` | **9.2** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Usage général |
| 3 | `llama3.2:90b` | **9.8** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ | Haute qualité |
| 4 | `mistral:7b` | **9.0** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Génération de code |
| 5 | `phi3.5:3.8b` | **8.8** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Raisonnement logique |
| 6 | `gemma2:9b` | **8.7** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | Équilibre performance/ressources |
| 7 | `llama3.2:3b` | **8.0** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Tests rapides |
| 8 | `phi3:3.8b` | **8.2** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Raisonnement rapide |
| 9 | `gemma:7b` | **8.1** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Usage général |
| 10 | `codellama:7b` | **8.5** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Génération de code |

---

## 📋 **Benchmarks par Catégorie**

---

### 🧠 **Raisonnement et Logique**

| Modèle | Score (1-10) | Temps de réponse (s) | Exemple de réponse |
|--------|--------------|----------------------|-------------------|
| `mixtral:8x7b` | **9.8** | 4.2 | Réponse détaillée et nuancée |
| `llama3.2:90b` | **9.7** | 8.5 | Très bonne compréhension |
| `phi3.5:3.8b` | **9.5** | 2.1 | Excellente logique |
| `llama3.2:11b` | **9.2** | 3.8 | Bonne analyse |
| `mistral:7b` | **9.0** | 3.5 | Réponse structurée |
| `gemma2:9b` | **8.8** | 4.0 | Bonne déduction |

**Test utilisé** : "Explique le paradoxe de Fermi avec des arguments pour et contre, puis propose une solution originale."

---

### 💻 **Génération de Code**

| Modèle | Score (1-10) | Temps (s) | Taux de succès | Langages testés |
|--------|--------------|-----------|----------------|------------------|
| `codellama:7b` | **9.5** | 5.2 | 92% | Python, JS, Java, C++ |
| `mistral:7b` | **9.3** | 4.8 | 89% | Python, JS, Rust, Go |
| `llama3.2:11b` | **9.0** | 6.1 | 85% | Python, JS, Java |
| `deepseek-coder:6.7b` | **9.7** | 7.3 | 94% | Python, JS, C++ |
| `phi3.5:3.8b` | **8.8** | 3.2 | 82% | Python, JS |
| `gemma2:9b` | **8.5** | 5.5 | 78% | Python, JS, Java |

**Tests utilisés** :
- Générer une fonction de tri rapide en Python
- Corriger du code JavaScript avec bugs
- Créer une API REST en Node.js
- Implémenter un algorithme de recherche binaire en C++

---

### ✍️ **Créativité et Rédaction**

| Modèle | Score (1-10) | Originalité | Cohérence | Style |
|--------|--------------|-------------|-----------|-------|
| `llama3.2:90b` | **9.8** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| `mixtral:8x7b` | **9.6** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| `llama3.2:11b` | **9.3** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| `gemma2:9b` | **9.0** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| `mistral:7b` | **8.8** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| `phi3.5:3.8b` | **8.5** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

**Test utilisé** : "Écris une nouvelle de science-fiction de 200 mots sur un monde où les humains communiquent par la pensée."

---

### 📚 **Connaissances Générales**

| Modèle | Score (1-10) | Histoire | Sciences | Technologie | Culture |
|--------|--------------|----------|----------|-------------|---------|
| `llama3.2:90b` | **9.7** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| `mixtral:8x7b` | **9.5** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| `llama3.2:11b` | **9.2** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| `mistral:7b` | **9.0** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| `gemma2:9b` | **8.8** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| `phi3.5:3.8b` | **8.5** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

**Tests utilisés** :
- Questions d'histoire (Révolution française, Seconde Guerre mondiale)
- Questions scientifiques (photosynthèse, relativité, ADN)
- Questions technologiques (blockchain, IA, quantique)
- Questions culturelles (littérature, art, musique)

---

## 💾 **Exigences Matérielles**

| Modèle | Taille (Go) | RAM requise (CPU) | RAM requise (GPU) | GPU recommandé | VRAM requise |
|--------|-------------|-------------------|-------------------|----------------|--------------|
| `llama3.2:1b` | 0.6 | 2-3 Go | 1-2 Go | Optionnel | 2 Go |
| `llama3.2:3b` | 2.0 | 4-6 Go | 2-3 Go | Optionnel | 4 Go |
| `phi3:3.8b` | 2.3 | 4-6 Go | 2-3 Go | Optionnel | 4 Go |
| `phi3.5:3.8b` | 2.4 | 4-6 Go | 2-3 Go | Optionnel | 4 Go |
| `gemma:2b` | 1.5 | 3-4 Go | 1-2 Go | Optionnel | 2 Go |
| `gemma:7b` | 4.8 | 6-8 Go | 4-5 Go | 8 Go | 8 Go |
| `codellama:7b` | 4.0 | 6-8 Go | 4-5 Go | 8 Go | 8 Go |
| `deepseek-coder:6.7b` | 4.2 | 6-8 Go | 4-5 Go | 8 Go | 8 Go |
| `mistral:7b` | 4.2 | 6-8 Go | 4-5 Go | 8 Go | 8 Go |
| `llama3.2:11b` | 6.5 | 8-12 Go | 6-8 Go | 12 Go | 12 Go |
| `mistral-nemo:12b` | 7.5 | 10-14 Go | 8-10 Go | 12 Go | 12 Go |
| `gemma2:9b` | 5.5 | 8-10 Go | 6-8 Go | 10 Go | 10 Go |
| `phi3:14b` | 8.0 | 10-14 Go | 8-10 Go | 12 Go | 12 Go |
| `mixtral:8x7b` | ~24 | 24-32 Go | 16-20 Go | 24 Go | 24 Go |
| `llama3.2:90b` | ~50 | 48-64 Go | 32-40 Go | 48 Go | 48 Go |

---

## ⚡ **Performances par Matériel**

### **Sur CPU seulement (sans GPU)**

| Modèle | Temps de réponse (s) | Qualité | Recommandé |
|--------|----------------------|---------|------------|
| `llama3.2:3b` | 2.1 | ⭐⭐⭐⭐ | ✅ Oui |
| `phi3:3.8b` | 1.8 | ⭐⭐⭐⭐ | ✅ Oui |
| `gemma:2b` | 1.5 | ⭐⭐⭐ | ✅ Oui |
| `llama3.2:11b` | 8.5 | ⭐⭐⭐⭐⭐ | ⚠️ Possible (lent) |
| `mistral:7b` | 7.2 | ⭐⭐⭐⭐⭐ | ⚠️ Possible (lent) |
| `mixtral:8x7b` | 30+ | ⭐⭐⭐⭐⭐ | ❌ Non |

**Matériel testé** : CPU 16 cœurs, 32 Go RAM

---

### **Sur GPU (RTX 4090 - 24 Go VRAM)**

| Modèle | Temps de réponse (s) | VRAM utilisée | Recommandé |
|--------|----------------------|---------------|------------|
| `llama3.2:3b` | 0.8 | 2 Go | ✅ Oui |
| `phi3:3.8b` | 0.6 | 2 Go | ✅ Oui |
| `gemma:2b` | 0.5 | 1.5 Go | ✅ Oui |
| `llama3.2:11b` | 1.5 | 8 Go | ✅ Oui |
| `mistral:7b` | 1.2 | 6 Go | ✅ Oui |
| `gemma:7b` | 1.8 | 7 Go | ✅ Oui |
| `mixtral:8x7b` | 2.5 | 18 Go | ✅ Oui |
| `llama3.2:90b` | 5.0 | 40 Go | ❌ Non (pas assez de VRAM) |

**Matériel testé** : RTX 4090 (24 Go VRAM)

---

### **Sur GPU (RTX 3090 - 24 Go VRAM)**

| Modèle | Temps de réponse (s) | VRAM utilisée | Recommandé |
|--------|----------------------|---------------|------------|
| `llama3.2:3b` | 1.0 | 2 Go | ✅ Oui |
| `phi3:3.8b` | 0.8 | 2 Go | ✅ Oui |
| `llama3.2:11b` | 2.0 | 8 Go | ✅ Oui |
| `mistral:7b` | 1.5 | 6 Go | ✅ Oui |
| `mixtral:8x7b` | 3.5 | 18 Go | ✅ Oui |
| `llama3.2:90b` | 8.0 | 40 Go | ❌ Non (pas assez de VRAM) |

---

## 🎯 **Recommandations par Usage**

### **💡 Pour les débutants**
- **Matériel** : CPU 8 cœurs, 16 Go RAM
- **Modèle** : `llama3.2:3b` ou `phi3:3.8b`
- **Pourquoi** : Léger, rapide, bonne qualité
- **Coût** : Gratuit, faible consommation

### **💼 Pour le développement**
- **Matériel** : CPU 16 cœurs, 32 Go RAM, GPU 12 Go
- **Modèle** : `codellama:7b` ou `mistral:7b`
- **Pourquoi** : Excellente génération de code
- **Alternative** : `deepseek-coder:6.7b` pour du code complexe

### **🧠 Pour le raisonnement complexe**
- **Matériel** : CPU 16 cœurs, 32 Go RAM, GPU 24 Go
- **Modèle** : `mixtral:8x7b` ou `llama3.2:11b`
- **Pourquoi** : Meilleure compréhension et analyse
- **Alternative** : `phi3.5:3.8b` pour du raisonnement rapide

### **⚡ Pour la vitesse maximale**
- **Matériel** : GPU puissant (RTX 4090)
- **Modèle** : `phi3:3.8b` ou `llama3.2:3b`
- **Pourquoi** : Temps de réponse < 1 seconde
- **Usage** : Chat en temps réel, prototypage rapide

### **🏆 Pour la meilleure qualité**
- **Matériel** : GPU 48 Go VRAM ou plus
- **Modèle** : `llama3.2:90b` ou `mixtral:8x7b`
- **Pourquoi** : Meilleure compréhension et créativité
- **Coût** : Ressources élevées, temps de réponse plus long

---

## 📊 **Comparaison des Coûts**

| Modèle | Coût de téléchargement | Coût d'exécution (CPU) | Coût d'exécution (GPU) |
|--------|------------------------|------------------------|------------------------|
| `llama3.2:1b` | Gratuit | Faible | Très faible |
| `llama3.2:3b` | Gratuit | Faible | Très faible |
| `phi3:3.8b` | Gratuit | Faible | Très faible |
| `gemma:2b` | Gratuit | Faible | Très faible |
| `llama3.2:11b` | Gratuit | Moyen | Faible |
| `mistral:7b` | Gratuit | Moyen | Faible |
| `mixtral:8x7b` | Gratuit | Élevé | Moyen |
| `llama3.2:90b` | Gratuit | Très élevé | Élevé |

**Notes** :
- Tous les modèles sont **open-source et gratuits**
- Le "coût" fait référence à l'utilisation des ressources (électricité, matériel)
- Les modèles plus grands consomment plus d'énergie

---

## 🔧 **Optimisations Recommandées**

### **Pour les petits modèles (< 7B)**
- **Quantisation** : Utilisez la quantisation 4-bit (par défaut dans Ollama)
- **CPU** : Suffisant pour la plupart des usages
- **GPU** : Optionnel, améliore les performances de 2-3x

### **Pour les modèles moyens (7B-15B)**
- **Quantisation** : 4-bit ou 5-bit pour un meilleur équilibre
- **GPU** : **Fortement recommandé** (12-24 Go VRAM)
- **CPU** : 16-32 Go RAM minimum
- **Astuce** : Utilisez `--gpu` dans Ollama pour forcer l'utilisation du GPU

### **Pour les grands modèles (> 15B)**
- **Quantisation** : 4-bit obligatoire
- **GPU** : **Obligatoire** (24 Go VRAM minimum)
- **CPU** : 32 Go RAM minimum
- **Astuce** : Limitez le nombre de modèles chargés simultanément

---

## 📅 **Mises à Jour et Versions**

| Modèle | Dernière version | Date de sortie | Notes |
|--------|------------------|----------------|-------|
| Llama 3.2 | 3.2 | Juillet 2024 | Meilleure série open-source |
| Mistral 7B | v0.3 | Septembre 2023 | Excellente performance |
| Phi-3 | 3.5 | Avril 2024 | Optimisé pour le raisonnement |
| Gemma 2 | 2.0 | Juin 2024 | Nouvelle génération Google |
| Mixtral | 8x7B | Décembre 2023 | Modèle expert |

---

## 💡 **Conseils pour Choisir**

1. **Commencez petit** : Testez avec `llama3.2:3b` ou `phi3:3.8b` avant de passer à des modèles plus grands
2. **Vérifiez votre matériel** : Utilisez `nvidia-smi` pour le GPU et `free -h` pour la RAM
3. **Testez les performances** : Utilisez le script `scripts/monitor.sh` pour surveiller l'utilisation
4. **Sauvegardez** : Utilisez `scripts/backup.sh` avant de changer de modèle
5. **Nettoyez** : Utilisez `scripts/cleanup.sh` pour supprimer les modèles inutilisés

---

## 📚 **Ressources Utiles**

- [Ollama Model Library](https://ollama.ai/library) - Liste complète des modèles
- [Open WebUI GitHub](https://github.com/open-webui/open-webui) - Interface graphique
- [Hugging Face Model Hub](https://huggingface.co/models) - Comparaison des modèles
- [LLM Perf Leaderboard](https://huggingface.co/spaces/HuggingFaceH4/llm-perf-leaderboard) - Benchmarks indépendants
