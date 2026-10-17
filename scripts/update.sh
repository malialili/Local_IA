#!/bin/bash

# Script pour mettre à jour Ollama et Open WebUI
# Utilisation: ./scripts/update.sh [OPTIONS]
# Exemple: ./scripts/update.sh
#          ./scripts/update.sh --check
#          ./scripts/update.sh --force

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

# Variables par défaut
CHECK_ONLY=false
FORCE_UPDATE=false
BACKUP_FIRST=true

# Fonction pour afficher l'aide
show_help() {
    echo "Utilisation: $0 [OPTIONS]"
    echo ""
    echo "Met à jour Ollama et Open WebUI vers les dernières versions."
    echo ""
    echo "Options:"
    echo "  -h, --help     Affiche cette aide"
    echo "  -c, --check    Vérifie les mises à jour sans les appliquer"
    echo "  -f, --force    Force la mise à jour (ignore les checks)"
    echo "  --no-backup    Ne pas sauvegarder avant la mise à jour"
    echo ""
    echo "Exemples:"
    echo "  $0              # Met à jour avec sauvegarde"
    echo "  $0 --check      # Vérifie les mises à jour disponibles"
    echo "  $0 --force      # Force la mise à jour"
    echo "  $0 --no-backup  # Met à jour sans sauvegarde"
}

# Analyser les arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--check)
            CHECK_ONLY=true
            shift
            ;;
        -f|--force)
            FORCE_UPDATE=true
            shift
            ;;
        --no-backup)
            BACKUP_FIRST=false
            shift
            ;;
        *)
            echo -e "${RED}❌ Option inconnue: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Fonction pour vérifier les mises à jour
check_updates() {
    echo -e "${BLUE}🔍 Vérification des mises à jour...${NC}"
    
    # Vérifier Ollama
    CURRENT_OLLAMA=$(docker exec ollama ollama --version 2>/dev/null | awk '{print $2}' || echo "inconnu")
    LATEST_OLLAMA=$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
    
    echo -e "\n${YELLOW}Ollama:${NC}"
    echo "  Version actuelle: $CURRENT_OLLAMA"
    echo "  Dernière version: $LATEST_OLLAMA"
    
    if [ "$CURRENT_OLLAMA" != "$LATEST_OLLAMA" ]; then
        echo -e "  ${GREEN}✅ Mise à jour disponible !${NC}"
        UPDATE_OLLAMA=true
    else
        echo -e "  ${BLUE}ℹ️  À jour${NC}"
        UPDATE_OLLAMA=false
    fi
    
    # Vérifier Open WebUI
    CURRENT_WEBUI=$(docker exec open-webui cat /app/backend/VERSION 2>/dev/null || echo "inconnu")
    LATEST_WEBUI=$(curl -s https://api.github.com/repos/open-webui/open-webui/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
    
    echo -e "\n${YELLOW}Open WebUI:${NC}"
    echo "  Version actuelle: $CURRENT_WEBUI"
    echo "  Dernière version: $LATEST_WEBUI"
    
    if [ "$CURRENT_WEBUI" != "$LATEST_WEBUI" ]; then
        echo -e "  ${GREEN}✅ Mise à jour disponible !${NC}"
        UPDATE_WEBUI=true
    else
        echo -e "  ${BLUE}ℹ️  À jour${NC}"
        UPDATE_WEBUI=false
    fi
    
    # Résumé
    echo ""
    if [ "$UPDATE_OLLAMA" = true ] || [ "$UPDATE_WEBUI" = true ]; then
        echo -e "${GREEN}✅ Des mises à jour sont disponibles${NC}"
        return 0
    else
        echo -e "${BLUE}ℹ️  Tout est à jour${NC}"
        return 1
    fi
}

# Fonction pour sauvegarder avant mise à jour
backup_before_update() {
    if [ "$BACKUP_FIRST" = true ]; then
        echo -e "${BLUE}💾 Sauvegarde avant mise à jour...${NC}"
        if ./scripts/backup.sh > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Sauvegarde terminée${NC}"
        else
            echo -e "${YELLOW}⚠️  La sauvegarde a échoué, continuation...${NC}"
        fi
    fi
}

# Fonction pour mettre à jour Ollama
update_ollama() {
    echo -e "${BLUE}🔄 Mise à jour de Ollama...${NC}"
    
    # Arrêter le conteneur
    docker stop ollama > /dev/null 2>&1
    
    # Tirer la dernière image
    docker pull ollama/ollama:latest
    
    # Redémarrer avec la nouvelle image
    docker start ollama > /dev/null 2>&1
    
    # Vérifier que tout fonctionne
    sleep 10
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Ollama mis à jour avec succès${NC}"
        return 0
    else
        echo -e "${RED}❌ Échec de la mise à jour de Ollama${NC}"
        return 1
    fi
}

# Fonction pour mettre à jour Open WebUI
update_webui() {
    echo -e "${BLUE}🔄 Mise à jour de Open WebUI...${NC}"
    
    # Arrêter le conteneur
    docker stop open-webui > /dev/null 2>&1
    
    # Tirer la dernière image
    docker pull ghcr.io/open-webui/open-webui:main
    
    # Redémarrer avec la nouvelle image
    docker start open-webui > /dev/null 2>&1
    
    # Vérifier que tout fonctionne
    sleep 10
    if curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Open WebUI mis à jour avec succès${NC}"
        return 0
    else
        echo -e "${RED}❌ Échec de la mise à jour de Open WebUI${NC}"
        return 1
    fi
}

# Si --check seulement
if [ "$CHECK_ONLY" = true ]; then
    check_updates
    exit 0
fi

# Vérifier s'il y a des mises à jour
check_updates
UPDATE_AVAILABLE=$?

if [ $UPDATE_AVAILABLE -ne 0 ] && [ "$FORCE_UPDATE" = false ]; then
    echo -e "${BLUE}ℹ️  Aucune mise à jour nécessaire${NC}"
    exit 0
fi

# Sauvegarder avant mise à jour
backup_before_update

# Mettre à jour
FAILED=0

if [ "$UPDATE_OLLAMA" = true ] || [ "$FORCE_UPDATE" = true ]; then
    if ! update_ollama; then
        FAILED=$((FAILED + 1))
    fi
fi

if [ "$UPDATE_WEBUI" = true ] || [ "$FORCE_UPDATE" = true ]; then
    if ! update_webui; then
        FAILED=$((FAILED + 1))
    fi
fi

# Résumé
if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Toutes les mises à jour ont été appliquées avec succès !${NC}"
else
    echo -e "${YELLOW}⚠️  $FAILED mise(s) à jour ont échoué${NC}"
fi

exit $FAILED
