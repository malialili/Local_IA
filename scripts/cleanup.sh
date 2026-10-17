#!/bin/bash

# Script pour nettoyer les modèles Ollama inutilisés
# Utilisation: ./scripts/cleanup.sh [OPTIONS]
# Exemple: ./scripts/cleanup.sh --dry-run
#          ./scripts/cleanup.sh --keep llama3.2:3b mistral:7b

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier que Docker est en cours d'exécution
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Erreur: Docker n'est pas en cours d'exécution${NC}"
    exit 1
fi

# Vérifier que le conteneur Ollama existe
if ! docker ps --format '{{.Names}}' | grep -q '^ollama$'; then
    echo -e "${RED}❌ Erreur: Le conteneur 'ollama' n'est pas en cours d'exécution${NC}"
    echo "Lancez 'docker compose -f docker/compose/base.yml up -d' d'abord."
    exit 1
fi

# Variables par défaut
DRY_RUN=false
KEEP_MODELS=()
ALL_MODELS=()

# Fonction pour afficher l'aide
show_help() {
    echo "Utilisation: $0 [OPTIONS]"
    echo ""
    echo "Nettoie les modèles Ollama inutilisés."
    echo ""
    echo "Options:"
    echo "  -h, --help         Affiche cette aide"
    echo "  -d, --dry-run      Simule le nettoyage sans rien supprimer"
    echo "  -k, --keep MODEL   Conserve le modèle spécifié (peut être utilisé plusieurs fois)"
    echo "  -a, --all          Supprime TOUS les modèles (attention !)"
    echo "  -l, --list         Liste les modèles disponibles"
    echo ""
    echo "Exemples:"
    echo "  $0 --dry-run                    # Simule le nettoyage"
    echo "  $0 --keep llama3.2:3b           # Conserve seulement llama3.2:3b"
    echo "  $0 --keep llama3.2:3b --keep mistral:7b  # Conserve plusieurs modèles"
    echo "  $0 --all                        # Supprime TOUS les modèles"
}

# Analyser les arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -a|--all)
            ALL_MODELS=("*")
            shift
            ;;
        -l|--list)
            echo -e "${BLUE}📋 Modèles Ollama locaux:${NC}"
            docker exec ollama ollama list
            exit 0
            ;;
        -k|--keep)
            if [ -n "$2" ]; then
                KEEP_MODELS+=("$2")
                shift 2
            else
                echo -e "${RED}❌ Erreur: --keep nécessite un nom de modèle${NC}"
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}❌ Option inconnue: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Récupérer la liste des modèles
MODEL_LIST=$(docker exec ollama ollama list 2>/dev/null | awk 'NR>1 {print $1}')

if [ -z "$MODEL_LIST" ]; then
    echo -e "${YELLOW}⚠️  Aucun modèle trouvé${NC}"
    exit 0
fi

# Si --all est spécifié, supprimer tout
if [ ${#ALL_MODELS[@]} -gt 0 ]; then
    echo -e "${RED}⚠️  ATTENTION: Vous êtes sur le point de supprimer TOUS les modèles !${NC}"
    read -p "Voulez-vous continuer ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✅ Opération annulée${NC}"
        exit 0
    fi
    
    for model in $MODEL_LIST; do
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Supprimerait: ${model}${NC}"
        else
            echo -e "${RED}🗑️  Suppression de: ${model}${NC}"
            docker exec ollama ollama rm "$model"
        fi
    done
    exit 0
fi

# Identifier les modèles à supprimer
MODELS_TO_REMOVE=()

for model in $MODEL_LIST; do
    should_keep=false
    for keep_model in "${KEEP_MODELS[@]}"; do
        if [[ "$model" == "$keep_model" ]]; then
            should_keep=true
            break
        fi
    done
    
    if [ "$should_keep" = false ]; then
        MODELS_TO_REMOVE+=("$model")
    fi
done

# Afficher le résumé
if [ ${#MODELS_TO_REMOVE[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ Aucun modèle à supprimer${NC}"
    if [ ${#KEEP_MODELS[@]} -gt 0 ]; then
        echo -e "${BLUE}📋 Modèles conservés:${NC}"
        for model in "${KEEP_MODELS[@]}"; do
            echo "  - $model"
        done
    fi
    exit 0
fi

echo -e "${RED}🗑️  Les modèles suivants seront supprimés:${NC}"
for model in "${MODELS_TO_REMOVE[@]}"; do
    echo "  - $model"
done

if [ ${#KEEP_MODELS[@]} -gt 0 ]; then
    echo -e "${BLUE}📋 Modèles conservés:${NC}"
    for model in "${KEEP_MODELS[@]}"; do
        echo "  - $model"
    done
fi

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}⏭️  Mode simulation: aucun modèle ne sera réellement supprimé${NC}"
    exit 0
fi

# Confirmer avant suppression
read -p "Voulez-vous continuer ? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}✅ Opération annulée${NC}"
    exit 0
fi

# Supprimer les modèles
FAILED=0
for model in "${MODELS_TO_REMOVE[@]}"; do
    echo -e "${RED}🗑️  Suppression de: ${model}${NC}"
    if docker exec ollama ollama rm "$model" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ ${model} supprimé avec succès${NC}"
    else
        echo -e "${RED}❌ Échec de la suppression de ${model}${NC}"
        FAILED=$((FAILED + 1))
    fi
done

# Afficher l'espace libéré
echo ""
echo -e "${BLUE}📊 Espace après nettoyage:${NC}"
docker exec ollama du -sh /root/.ollama/models/ 2>/dev/null || echo "Impossible de calculer l'espace."

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Nettoyage terminé avec succès !${NC}"
else
    echo -e "${YELLOW}⚠️  $FAILED modèle(s) n'ont pas pu être supprimés${NC}"
fi

exit $FAILED
