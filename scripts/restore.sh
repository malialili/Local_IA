#!/bin/bash

# Script pour restaurer les données Ollama et Open WebUI
# Utilisation: ./scripts/restore.sh [FICHIER]
# Exemple: ./scripts/restore.sh ./backups/llm_backup_20241017.tar.gz
#          ./scripts/restore.sh --list

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
    echo "Utilisation: $0 [OPTIONS] [FICHIER]"
    echo ""
    echo "Restaure les données Ollama et Open WebUI depuis une sauvegarde."
    echo ""
    echo "Arguments:"
    echo "  FICHIER    Chemin vers le fichier de sauvegarde .tar.gz"
    echo ""
    echo "Options:"
    echo "  -h, --help     Affiche cette aide"
    echo "  -l, --list     Liste les sauvegardes disponibles"
    echo "  -f, --force    Force la restauration (sans confirmation)"
    echo "  -o, --ollama   Restaure uniquement Ollama"
    echo "  -w, --webui    Restaure uniquement Open WebUI"
    echo "  -a, --all      Restaure tout (par défaut)"
    echo ""
    echo "Exemples:"
    echo "  $0 ./backups/llm_backup_20241017.tar.gz"
    echo "  $0 --list"
    echo "  $0 --ollama ./backups/ollama_only.tar.gz"
}

# Variables par défaut
RESTORE_ALL=true
RESTORE_OLLAMA=false
RESTORE_WEBUI=false
FORCE=false
BACKUP_DIR="./backups/"

# Analyser les arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -l|--list)
            echo -e "${BLUE}📋 Sauvegardes disponibles dans ${BACKUP_DIR}:${NC}"
            ls -lh "$BACKUP_DIR"llm_backup_*.tar.gz 2>/dev/null || echo "Aucune sauvegarde trouvée."
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -o|--ollama)
            RESTORE_ALL=false
            RESTORE_OLLAMA=true
            shift
            ;;
        -w|--webui)
            RESTORE_ALL=false
            RESTORE_WEBUI=true
            shift
            ;;
        -a|--all)
            RESTORE_ALL=true
            shift
            ;;
        -*)
            echo -e "${RED}❌ Option inconnue: $1${NC}"
            show_help
            exit 1
            ;;
        *)
            BACKUP_FILE="$1"
            shift
            ;;
    esac
done

# Si restore tout, activer les deux
if [ "$RESTORE_ALL" = true ]; then
    RESTORE_OLLAMA=true
    RESTORE_WEBUI=true
fi

# Vérifier qu'un fichier de sauvegarde est spécifié
if [ -z "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Erreur: Aucun fichier de sauvegarde spécifié${NC}"
    echo "Utilisez --list pour voir les sauvegardes disponibles."
    exit 1
fi

# Vérifier que le fichier existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Erreur: Fichier non trouvé: $BACKUP_FILE${NC}"
    exit 1
fi

# Vérifier que les conteneurs sont en cours d'exécution
MISSING_CONTAINERS=()

if [ "$RESTORE_OLLAMA" = true ]; then
    if ! docker ps --format '{{.Names}}' | grep -q '^ollama$'; then
        MISSING_CONTAINERS+=("ollama")
    fi
fi

if [ "$RESTORE_WEBUI" = true ]; then
    if ! docker ps --format '{{.Names}}' | grep -q '^open-webui$'; then
        MISSING_CONTAINERS+=("open-webui")
    fi
fi

if [ ${#MISSING_CONTAINERS[@]} -gt 0 ]; then
    echo -e "${RED}❌ Erreur: Les conteneurs suivants ne sont pas en cours d'exécution:${NC}"
    for container in "${MISSING_CONTAINERS[@]}"; do
        echo "  - $container"
    done
    echo "Lancez 'docker compose -f docker/compose/base.yml up -d' d'abord."
    exit 1
fi

# Afficher les informations de la sauvegarde
echo -e "${BLUE}📁 Restauration depuis:${NC} $BACKUP_FILE"
SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo -e "${BLUE}📊 Taille:${NC} $SIZE"

# Demander confirmation si pas --force
if [ "$FORCE" = false ]; then
    echo ""
    echo -e "${RED}⚠️  ATTENTION: Cette opération écrasera les données existantes !${NC}"
    read -p "Voulez-vous continuer ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✅ Opération annulée${NC}"
        exit 0
    fi
fi

# Arrêter les conteneurs pendant la restauration
echo -e "${BLUE}🛑 Arrêt des conteneurs...${NC}"
if [ "$RESTORE_OLLAMA" = true ]; then
    docker stop ollama > /dev/null 2>&1
fi
if [ "$RESTORE_WEBUI" = true ]; then
    docker stop open-webui > /dev/null 2>&1
fi

# Fonction pour restaurer un volume
restore_volume() {
    local volume_name="$1"
    local container_name="$2"
    local mount_point="$3"
    local backup_file="$4"
    
    echo -e "${BLUE}🔄 Restauration de ${YELLOW}${volume_name}${BLUE}...${NC}"
    
    # Vérifier que le volume existe
    if ! docker volume inspect "$volume_name" > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Volume ${volume_name} non trouvé, création...${NC}"
        docker volume create "$volume_name"
    fi
    
    # Créer un conteneur temporaire pour la restauration
    local temp_container="restore_temp_${volume_name}_${RANDOM}"
    
    if docker run --rm \
        -v "$volume_name":/data \
        -v "$(dirname "$backup_file"):/backup" \
        --name "$temp_container" \
        busybox \
        sh -c "rm -rf /data/* && tar xzf /backup/$(basename "$backup_file") -C /data" 2>/dev/null; then
        echo -e "${GREEN}✅ ${volume_name} restauré avec succès${NC}"
        return 0
    else
        echo -e "${RED}❌ Échec de la restauration de ${volume_name}${NC}"
        return 1
    fi
}

# Restaurer les volumes
FAILED=0

if [ "$RESTORE_OLLAMA" = true ]; then
    if ! restore_volume "ollama_data" "ollama" "/root/.ollama" "$BACKUP_FILE"; then
        FAILED=$((FAILED + 1))
    fi
fi

if [ "$RESTORE_WEBUI" = true ]; then
    if ! restore_volume "open_webui_data" "open-webui" "/app/backend/data" "$BACKUP_FILE"; then
        FAILED=$((FAILED + 1))
    fi
fi

# Redémarrer les conteneurs
echo -e "${BLUE}🚀 Redémarrage des conteneurs...${NC}"
if [ "$RESTORE_OLLAMA" = true ]; then
    docker start ollama > /dev/null 2>&1
fi
if [ "$RESTORE_WEBUI" = true ]; then
    docker start open-webui > /dev/null 2>&1
fi

# Afficher le résumé
if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Restauration terminée avec succès !${NC}"
    echo -e "${BLUE}📝 Vous pouvez maintenant utiliser vos données restaurées${NC}"
else
    echo -e "${YELLOW}⚠️  $FAILED restauration(s) ont échoué${NC}"
fi

exit $FAILED
