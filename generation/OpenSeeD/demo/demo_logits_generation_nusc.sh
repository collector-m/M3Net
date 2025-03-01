#!/usr/bin/env bash

set -x

PARTITION=$1
JOB_NAME=$2
GPUS=$3
PY_ARGS=${@:4}

GPUS_PER_NODE=1
CPUS_PER_TASK=16
SRUN_ARGS=${SRUN_ARGS:-""}

while true
do
    PORT=$(( ((RANDOM<<15)|RANDOM) % 49152 + 10000 ))
    status="$(nc -z 127.0.0.1 $PORT < /dev/null &>/dev/null; echo $?)"
    if [ "${status}" != "0" ]; then
        break;
    fi
done
echo $PORT

srun -p ${PARTITION} \
    --job-name=${JOB_NAME} \
    --gres=gpu:${GPUS_PER_NODE} \
    --ntasks=${GPUS} \
    --quotatype=auto \
    --ntasks-per-node=${GPUS_PER_NODE} \
    --cpus-per-task=${CPUS_PER_TASK} \
    --kill-on-bad-exit=1 \
    ${SRUN_ARGS} \
    python demo_logits_generation_nusc.py evaluate --conf_files /root/OpenSeeD/configs/openseed/openseed_swint_lang.yaml   --overrides WEIGHT /root/OpenSeeD/demo/model_state_dict_swint_51.2ap.pt