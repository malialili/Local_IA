#!/bin/bash

# Script pour sauvegarder les données Ollama et Open WebUI
# Utilisation: ./scripts/backup.sh [DESTINATION]
# Exemple: ./scripts/backup.sh ./backups/
#          ./scripts/backup.sh /mnt/backup/llm/

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

# Fonction pour afficher l'aide
show_help() {
    echo "Utilisation: $0 [OPTIONS] [DESTINATION]"
    echo ""
    echo "Sauvegarde les modèles Ollama et les données Open WebUI."
    echo ""
    echo "Arguments:"
    echo "  DESTINATION    Dossier de destination pour la sauvegarde (par défaut: ./backups/)"
    echo ""
    echo "Options:"
    echo "  -h, --help     Affiche cette aide"
    echo "  -o, --ollama   Sauvegarde uniquement Ollama"
    echo "  -w, --webui    Sauvegarde uniquement Open WebUI"
    echo "  -a, --all      Sauvegarde tout (par défaut)"
    echo "  -c, --cleanup  Supprime les sauvegardes de plus de 30 jours"
    echo ""
    echo "Exemples:"
    echo "  $0 ./backups/"
    echo "  $0 --ollama ./ollama_backups/"
    echo "  $0 --webui ./webui_backups/"
    echo "  $0 --cleanup"
}

# Variables par défaut
BACKUP_ALL=true
BACKUP_OLLAMA=false
BACKUP_WEBUI=false
DESTINATION="./backups/"
CLEANUP=false

# Analyser les arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--ollama)
            BACKUP_ALL=false
            BACKUP_OLLAMA=true
            shift
            ;;
        -w|--webui)
            BACKUP_ALL=false
            BACKUP_WEBUI=true
            shift
            ;;
        -a|--all)
            BACKUP_ALL=true
            shift
            ;;
        -c|--cleanup)
            CLEANUP=true
            shift
            ;;
        -*)
            echo -e "${RED}❌ Option inconnue: $1${NC}"
            show_help
            exit 1
            ;;
        *)
            DESTINATION="$1"
            shift
            ;;
    esac
done

# Si backup tout, activer les deux
if [ "$BACKUP_ALL" = true ]; then
    BACKUP_OLLAMA=true
    BACKUP_WEBUI=true
fi

# Créer le dossier de destination si nécessaire
mkdir -p "$DESTINATION"

# Nom du fichier de sauvegarde (avec timestamp)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="llm_backup_${TIMESTAMP}"
BACKUP_FILE="${DESTINATION}${BACKUP_NAME}.tar.gz"

# Fonction pour sauvegarder un volume
backup_volume() {
    local volume_name="$1"
    local container_name="$2"
    local mount_point="$3"
    local backup_file="$4"
    
    echo -e "${BLUE}💾 Sauvegarde de ${YELLOW}${volume_name}${BLUE}...${NC}"
    
    # Vérifier que le volume existe
    if ! docker volume inspect "$volume_name" > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Volume ${volume_name} non trouvé, ignoré${NC}"
        return 0
    fi
    
    # Créer un conteneur temporaire pour la sauvegarde
    local temp_container="backup_temp_${volume_name}_${TIMESTAMP}"
    
    docker run --rm \
        -v "$volume_name":/data \
        -v "$(dirname "$backup_file"):/backup" \
        --name "$temp_container" \
        busybox \
        tar czf "/backup/$(basename "$backup_file")" -C /data . 2>/dev/null || {
        echo -e "${RED}❌ Échec de la sauvegarde de ${volume_name}${NC}"
        return 1
    }
    
    echo -e "${GREEN}✅ ${volume_name} sauvegardé dans ${backup_file}${NC}"
    return 0
}

# Fonction pour nettoyer les anciennes sauvegardes
cleanup_old_backups() {
    echo -e "${BLUE}🧹 Nettoyage des sauvegardes anciennes...${NC}"
    
    find "$DESTINATION" -name "llm_backup_*.tar.gz" -mtime +30 -exec ls -lh {} \; 2>/dev/null | while read -r line; do
        file=$(echo "$line" | awk '{print $NF}')
        echo -e "${YELLOW}🗑️  Suppression de: ${file}${NC}"
        rm -f "$file"
    done
    
    echo -e "${GREEN}✅ Nettoyage terminé${NC}"
}

# Exécuter le nettoyage si demandé
if [ "$CLEANUP" = true ]; then
    cleanup_old_backups
    exit 0
fi

# Sauvegarder les volumes
FAILED=0

if [ "$BACKUP_OLLAMA" = true ]; then
    if ! backup_volume "ollama_data" "ollama" "/root/.ollama" "$BACKUP_FILE"; then
        FAILED=$((FAILED + 1))
    fi
fi

if [ "$BACKUP_WEBUI" = true ]; then
    if ! backup_volume "open_webui_data" "open-webui" "/app/backend/data" "$BACKUP_FILE"; then
        FAILED=$((FAILED + 1))
    fi
fi

# Afficher le résumé
if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Sauvegarde terminée avec succès !${NC}"
    echo -e "${BLUE}📁 Fichier de sauvegarde:${NC} $BACKUP_FILE"
    
    # Afficher la taille du fichier
    if [ -f "$BACKUP_FILE" ]; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo -e "${BLUE}📊 Taille:${NC} $SIZE"
    fi
else
    echo -e "${YELLOW}⚠️  $FAILED sauvegarde(s) ont échoué${NC}"
fi

exit $FAILED
