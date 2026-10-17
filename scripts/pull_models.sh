#!/bin/bash

# Script pour télécharger des modèles Ollama
# Utilisation: ./pull_models.sh [model1] [model2] ...
# Exemple: ./pull_models.sh llama3.2:3b mistral:7b

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
    echo "Démarrez Docker et réessayez."
    exit 1
fi

# Vérifier que le conteneur Ollama existe
if ! docker ps --format '{{.Names}}' | grep -q '^ollama$'; then
    echo -e "${RED}❌ Erreur: Le conteneur 'ollama' n'est pas en cours d'exécution${NC}"
    echo "Lancez 'docker compose up -d' d'abord."
    exit 1
fi

# Fonction pour télécharger un modèle
download_model() {
    local model="$1"
    echo -e "${BLUE}📥 Téléchargement de ${YELLOW}${model}${BLUE}...${NC}"
    
    if docker exec ollama ollama list | grep -q "${model}"; then
        echo -e "${GREEN}✅ Modèle ${model} déjà téléchargé${NC}"
        return 0
    fi
    
    if docker exec ollama ollama pull "${model}" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Modèle ${model} téléchargé avec succès${NC}"
    else
        echo -e "${RED}❌ Échec du téléchargement de ${model}${NC}"
        return 1
    fi
}

# Fonction pour afficher l'aide
show_help() {
    echo "Utilisation: $0 [OPTIONS] [MODEL1] [MODEL2] ..."
    echo ""
    echo "Télécharge des modèles Ollama pour une utilisation locale."
    echo ""
    echo "Options:"
    echo "  -h, --help       Affiche cette aide"
    echo "  -l, --list       Liste les modèles disponibles localement"
    echo "  -a, --all        Télécharge tous les modèles recommandés"
    echo "  -c, --code       Télécharge les modèles spécialisés en code"
    echo "  -s, --small      Télécharge les modèles légers (< 5 Go)"
    echo ""
    echo "Exemples:"
    echo "  $0 llama3.2:3b mistral:7b"
    echo "  $0 --all"
    echo "  $0 --code"
    echo "  $0 --list"
    echo ""
    echo "Modèles disponibles:"
    echo "  Llama: llama3.2:1b, llama3.2:3b, llama3.2:11b"
    echo "  Mistral: mistral:7b, mistral-nemo:12b"
    echo "  Phi: phi3:3.8b, phi3.5:3.8b"
    echo "  Gemma: gemma:2b, gemma:7b, gemma2:9b"
    echo "  Code: codellama:7b, codegemma:7b, deepseek-coder:6.7b"
}

# Fonction pour lister les modèles locaux
list_models() {
    echo -e "${BLUE}📋 Modèles locaux:${NC}"
    docker exec ollama ollama list || echo "Aucun modèle téléchargé."
}

# Modèles par catégorie
declare -A ALL_MODELS=(
    [llama]="llama3.2:1b llama3.2:3b llama3.2:11b"
    [mistral]="mistral:7b mistral-nemo:12b"
    [phi]="phi3:3.8b phi3.5:3.8b"
    [gemma]="gemma:2b gemma:7b gemma2:9b"
    [code]="codellama:7b codegemma:7b deepseek-coder:6.7b"
)

# Tous les modèles
ALL_MODEL_LIST=()
for category in "${!ALL_MODELS[@]}"; do
    ALL_MODEL_LIST+=(${ALL_MODELS[$category]})
done

# Modèles légers (< 5 Go)
SMALL_MODELS=("llama3.2:1b" "llama3.2:3b" "phi3:3.8b" "phi3.5:3.8b" "gemma:2b")

# Modèles code
CODE_MODELS=("codellama:7b" "codegemma:7b" "deepseek-coder:6.7b")

# Analyser les arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

ACTION=""
MODELS_TO_PULL=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -l|--list)
            list_models
            exit 0
            ;;
        -a|--all)
            MODELS_TO_PULL=("${ALL_MODEL_LIST[@]}")
            shift
            ;;
        -c|--code)
            MODELS_TO_PULL+=("${CODE_MODELS[@]}")
            shift
            ;;
        -s|--small)
            MODELS_TO_PULL+=("${SMALL_MODELS[@]}")
            shift
            ;;
        *)
            MODELS_TO_PULL+=("$1")
            shift
            ;;
    esac
done

# Supprimer les doublons
MODELS_TO_PULL=($(printf "%s\n" "${MODELS_TO_PULL[@]}" | sort -u | tr '\n' ' '))

if [ ${#MODELS_TO_PULL[@]} -eq 0 ]; then
    show_help
    exit 0
fi

# Afficher le résumé
echo -e "${YELLOW}🎯 Résumé du téléchargement:${NC}"
for model in "${MODELS_TO_PULL[@]}"; do
    echo "  - ${model}"
done
echo ""

# Télécharger les modèles
FAILED=0
for model in "${MODELS_TO_PULL[@]}"; do
    if ! download_model "$model"; then
        FAILED=$((FAILED + 1))
    fi
done

# Résumé final
echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Tous les modèles ont été téléchargés avec succès !${NC}"
else
    echo -e "${YELLOW}⚠️  $FAILED modèle(s) n'ont pas pu être téléchargés${NC}"
fi

echo -e "${BLUE}📊 Espace utilisé:${NC}"
docker exec ollama du -sh /root/.ollama/models/ 2>/dev/null || echo "Impossible de calculer l'espace."

exit $FAILED
