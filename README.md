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

Load system modules for mamba and Cray MPICH.
```
ml mamba cray-mpich
```

Create mamba env where PyTorch (and a GCC newer than 9.3, but older than GCC 12) will live. We are also installing mkl and blas from conda to avoid the use of Intel modules on Kestrel (because the CPU hardware on the GPUs are AMD, not Intel), as well as a few other dependencies (including cuda, cudatoolkit, and cudnn). Despite the use of mamba, we will still build PyTorch from scratch to include our NCCL library. 
```
mamba env create -f environment.yaml --prefix=`pwd`/pytorch-with-nccl-env
conda activate ./pytorch-with-nccl-env 
```

Set build variables for PyTorch.
```
export CC=gcc
export CXX=g++
export MPICH_GPU_SUPPORT_ENABLED=0
export USE_CUDA=1
export CUDA_HOME=$CONDA_PREFIX
export CUDA_INCLUDE_DIRS=$CUDA_HOME/include
export USE_MPI=1
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

I am somehow missing CUDA (even though its version is detected...), probably a missing variable or something. CUDA is installed into the conda environment and seems to be found by other dependencies, but Caffe2 is causing the entire build to be CPU-only:
 
```
-- Could NOT find CUDA (missing: CUDA_INCLUDE_DIRS) (found version "12.4")
CMake Warning at cmake/public/cuda.cmake:31 (message):
  Caffe2: CUDA cannot be found.  Depending on whether you are building Caffe2
  or a Caffe2 dependent library, the next warning / error will give you more
  info.

```
