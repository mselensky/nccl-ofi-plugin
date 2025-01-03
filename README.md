# nccl-ofi-plugin

This package is used to build NCCL with the OFI plugin for use at NERSC.
The plugin is provided by AWS at https://github.com/aws/aws-ofi-nccl
with modifications by Jim Dinan at NVIDIA.

Build the plugin with
  > sbatch build_plugin.sh

Run on H100s with
  > sbatch run_tests.sh

# NREL

# Building PyTorch with custom NCCL-ofi plugin on Kestrel

Load system modules.
```
ml PrgEnv-nvhpc cudnn/9.2.0.82-12 cuda/12.3 mamba
```

Create mamba env where PyTorch (and a GCC newer than 9.3, but older than GCC 12) will live. We are also installing mkl and blas from conda to avoid the use of Intel modules on Kestrel (because the CPU hardware on the GPUs are AMD, not Intel). Despite the use of mamba, we will still build it from scratch to include our NCCL library. 
```
mamba create --prefix=`pwd`/pytorch-with-nccl-env python=3.11 numpy pyyaml gxx=10 gcc=10 mkl blas=*=*mkl -y
conda activate `pwd`/pytorch-with-nccl-env 
```

Set build variables for PyTorch.
```
export CC=gcc
export CXX=g++
export MPICH_GPU_SUPPORT_ENABLED=0
export USE_CUDA=1
export USE_DISTRIBUTED=1
export TORCH_CUDA_ARCH_LIST=9.0
export USE_SYSTEM_NCCL=1
```

Set variables to find custom NCCL library.
```
source env_nccl.sh 
```

Clone source code of PyTorch and its dependencies. Note that v2.4.1 of PyTorch is compatible with CUDA 12.4.
```
git clone --recursive --branch v2.4.1 https://github.com/pytorch/pytorch.git
cd pytorch/
python setup.py install
```

I am still working through some dependency-related errors here - this currently will not build, but I think I'm pretty close. Still need figure out how to get it to recognize the custom path to our NCCL plugin. 
