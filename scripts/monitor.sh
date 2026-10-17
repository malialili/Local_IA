#!/bin/bash

# Script pour monitorer l'utilisation des ressources par Ollama et Open WebUI
# Utilisation: ./scripts/monitor.sh [OPTIONS]
# Exemple: ./scripts/monitor.sh
#          ./scripts/monitor.sh --continuous
#          ./scripts/monitor.sh --interval 5

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Vérifier que Docker est en cours d'exécution
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Erreur: Docker n'est pas en cours d'exécution${NC}"
    exit 1
fi

# Variables par défaut
CONTINUOUS=false
INTERVAL=2
SHOW_GPU=true
SHOW_CPU=true
SHOW_MEM=true
SHOW_DISK=true

# Fonction pour afficher l'aide
show_help() {
    echo "Utilisation: $0 [OPTIONS]"
    echo ""
    echo "Affiche l'utilisation des ressources par Ollama et Open WebUI."
    echo ""
    echo "Options:"
    echo "  -h, --help         Affiche cette aide"
    echo "  -c, --continuous   Affiche en continu (rafraîchissement toutes les N secondes)"
    echo "  -i, --interval N   Intervalle de rafraîchissement en secondes (par défaut: 2)"
    echo "  --no-gpu          Ne pas afficher les infos GPU"
    echo "  --no-cpu          Ne pas afficher les infos CPU"
    echo "  --no-mem          Ne pas afficher les infos mémoire"
    echo "  --no-disk         Ne pas afficher les infos disque"
    echo ""
    echo "Exemples:"
    echo "  $0              # Affiche une fois"
    echo "  $0 --continuous # Affiche en continu toutes les 2 secondes"
    echo "  $0 --continuous --interval 5 # Rafraîchissement toutes les 5 secondes"
    echo "  $0 --no-gpu     # Sans infos GPU"
}

# Analyser les arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--continuous)
            CONTINUOUS=true
            shift
            ;;
        -i|--interval)
            if [ -n "$2" ]; then
                INTERVAL="$2"
                shift 2
            else
                echo -e "${RED}❌ Erreur: --interval nécessite une valeur${NC}"
                exit 1
            fi
            ;;
        --no-gpu)
            SHOW_GPU=false
            shift
            ;;
        --no-cpu)
            SHOW_CPU=false
            shift
            ;;
        --no-mem)
            SHOW_MEM=false
            shift
            ;;
        --no-disk)
            SHOW_DISK=false
            shift
            ;;
        *)
            echo -e "${RED}❌ Option inconnue: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Fonction pour afficher l'en-tête
print_header() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${MAGENTA}Local IA - Monitoring des ressources${NC} ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Fonction pour obtenir les stats d'un conteneur
get_container_stats() {
    local container_name="$1"
    local prefix="$2"
    
    # Vérifier si le conteneur existe
    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo -e "${RED}❌ Conteneur ${container_name} non trouvé${NC}"
        return 1
    fi
    
    # Obtenir les stats Docker
    local stats
    stats=$(docker stats --no-stream --format "{{.CPUPerc}}|{{.MemUsage}}|{{.MemPerc}}|{{.NetIO}}|{{.BlockIO}}" "$container_name" 2>/dev/null)
    
    if [ -z "$stats" ]; then
        echo -e "${YELLOW}⚠️  Impossible d'obtenir les stats pour ${container_name}${NC}"
        return 1
    fi
    
    # Parser les stats
    local cpu_perc=$(echo "$stats" | cut -d'|' -f1 | tr -d ' ')
    local mem_usage=$(echo "$stats" | cut -d'|' -f2 | tr -d ' ')
    local mem_perc=$(echo "$stats" | cut -d'|' -f3 | tr -d ' ')
    local net_io=$(echo "$stats" | cut -d'|' -f4 | tr -d ' ')
    local block_io=$(echo "$stats" | cut -d'|' -f5 | tr -d ' ')
    
    # Afficher les stats
    echo -e "${BLUE}${prefix}${NC}"
    
    if [ "$SHOW_CPU" = true ]; then
        echo -e "  ${CYAN}CPU:${NC} ${cpu_perc}"
    fi
    
    if [ "$SHOW_MEM" = true ]; then
        echo -e "  ${CYAN}Mémoire:${NC} ${mem_usage} (${mem_perc})"
    fi
    
    if [ "$SHOW_DISK" = true ]; then
        # Obtenir l'utilisation du disque pour le volume du conteneur
        local volume_name
        case "$container_name" in
            "ollama")
                volume_name="ollama_data"
                ;;
            "open-webui")
                volume_name="open_webui_data"
                ;;
            *)
                volume_name=""
                ;;
        esac
        
        if [ -n "$volume_name" ]; then
            local disk_usage
            disk_usage=$(docker system df -v 2>/dev/null | grep "$volume_name" | awk '{print $2, $3}' | tr -d ' ')
            if [ -n "$disk_usage" ]; then
                echo -e "  ${CYAN}Disque:${NC} ${disk_usage}"
            fi
        fi
    fi
    
    return 0
}

# Fonction pour obtenir les infos GPU
get_gpu_stats() {
    if [ "$SHOW_GPU" = false ]; then
        return 0
    fi
    
    # Vérifier si nvidia-smi est disponible
    if ! command -v nvidia-smi &> /dev/null; then
        echo -e "${YELLOW}⚠️  nvidia-smi non trouvé, infos GPU non disponibles${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🎮 GPU:${NC}"
    
    # Obtenir les infos GPU
    local gpu_info
    gpu_info=$(nvidia-smi --query-gpu=utilization.gpu,utilization.memory,temperature.gpu,power.draw --format=csv,noheader 2>/dev/null)
    
    if [ -n "$gpu_info" ]; then
        local gpu_util=$(echo "$gpu_info" | cut -d',' -f1 | tr -d ' ')
        local mem_util=$(echo "$gpu_info" | cut -d',' -f2 | tr -d ' ')
        local temp=$(echo "$gpu_info" | cut -d',' -f3 | tr -d ' ')
        local power=$(echo "$gpu_info" | cut -d',' -f4 | tr -d ' ')
        
        echo -e "  ${CYAN}Utilisation GPU:${NC} ${gpu_util}"
        echo -e "  ${CYAN}Utilisation mémoire GPU:${NC} ${mem_util}"
        echo -e "  ${CYAN}Température:${NC} ${temp}"
        echo -e "  ${CYAN}Consommation:${NC} ${power}"
    else
        echo -e "  ${YELLOW}⚠️  Impossible d'obtenir les infos GPU${NC}"
    fi
    
    return 0
}

# Fonction pour obtenir les modèles chargés
get_loaded_models() {
    echo -e "${BLUE}🧠 Modèles chargés:${NC}"
    
    if docker exec ollama ollama list 2>/dev/null | grep -q .; then
        docker exec ollama ollama list 2>/dev/null | sed 's/^/  /'
    else
        echo -e "  ${YELLOW}⚠️  Impossible de lister les modèles${NC}"
    fi
}

# Fonction pour afficher les stats
print_stats() {
    print_header
    
    # Stats Ollama
    get_container_stats "ollama" "🐋 Ollama:"
    echo ""
    
    # Stats Open WebUI
    get_container_stats "open-webui" "🌐 Open WebUI:"
    echo ""
    
    # Infos GPU
    get_gpu_stats
    echo ""
    
    # Modèles chargés
    get_loaded_models
    echo ""
    
    # Date et heure
    echo -e "${BLUE}📅 Dernière mise à jour:${NC} $(date +'%Y-%m-%d %H:%M:%S')"
}

# Afficher une fois ou en continu
if [ "$CONTINUOUS" = true ]; then
    while true; do
        print_stats
        sleep "$INTERVAL"
    done
else
    print_stats
fi
