#!/bin/bash
#SBATCH -A hpcapps
#SBATCH -p gpu-h100
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --gres=gpu:4
#SBATCH --mem=0
#SBATCH --time=00:10:00
#SBATCH --job-name=nccl_slingshot_test
#SBATCH -o %j-%x.out

module load cuda/12.3

export NCCL_HOME=$PWD/nccl-ofi-plugin/install
export MPICH_GPU_SUPPORT_ENABLED=0

export LD_LIBRARY_PATH=$NCCL_HOME/lib:$NCCL_HOME/plugin/lib:$LD_LIBRARY_PATH
export FI_CXI_DISABLE_HOST_REGISTER=1
export FI_MR_CACHE_MONITOR=userfaultfd
export NCCL_CROSS_NIC=1
export NCCL_DEBUG=INFO
export NCCL_SOCKET_IFNAME=hsn
export NCCL_NET="AWS Libfabric"
export NCCL_NET_GDR_LEVEL=PHB

echo ========== RUNNING NCCL TESTS ==========
srun $PWD/nccl-ofi-plugin/nccl-tests/build/all_reduce_perf -b 8 -e 4G -f 2
