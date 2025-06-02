#!/bin/bash
# Sample commands to deploy nuclio functions on GPU
export DOCKER_DEFAULT_PLATFORM=linux/amd64

set -eu

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
FUNCTIONS_DIR=${1:-$SCRIPT_DIR}

nuctl create project cvat --platform local

find "$FUNCTIONS_DIR" -type f -name 'function-gpu.yaml' | while read -r func_config; do
    func_root="$(dirname "$func_config")"
    func_rel_path=$(python3 -c "import os.path; print(os.path.relpath('$func_root', '$SCRIPT_DIR'))")

    echo "Deploying $func_rel_path function..."
    nuctl deploy --project-name cvat --path "$func_root" \
        --file "$func_config" --platform local \
        --env CVAT_FUNCTIONS_REDIS_HOST=cvat_redis_ondisk \
        --env CVAT_FUNCTIONS_REDIS_PORT=6666 \
        --platform-config '{"attributes": {"network": "cvat_cvat"}}'
done

nuctl get function --platform local
