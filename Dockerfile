FROM nvidia/cuda:11.4.3-runtime-ubuntu20.04 as base
#FROM nvidia/cuda:11.4.3-base-ubuntu20.04 as base
#FROM nvidia/cuda:11.4.3-cudnn8-runtime-ubuntu20.04 as base
#FROM nvidia/cuda:11.4.3-devel-ubuntu20.04 as base
#FROM nvidia/cuda:12.1.0-runtime-ubuntu20.04 as base
#FROM nvidia/cuda:12.3.2-runtime-ubuntu20.04 as base

FROM base as base-amd64

#Cuda 11
ENV NV_CUDNN_VERSION 8.2.4.15
ENV NV_CUDNN_PACKAGE_NAME "libcudnn8"
ENV NV_CUDNN_PACKAGE "libcudnn8=8.2.4.15-1+cuda11.4"

#Cuda 12
#ENV NV_CUDNN_VERSION 9.0.0.312
#ENV NV_CUDNN_PACKAGE_NAME "libcudnn9-cuda-12"
#ENV NV_CUDNN_PACKAGE "libcudnn9-cuda-12=${NV_CUDNN_VERSION}-1"

FROM base-${TARGETARCH}

ARG TARGETARCH

LABEL maintainer "Kristof Kiekens <kristof.kiekens@gmail.com>"
LABEL com.nvidia.cudnn.version="${NV_CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} \
    && apt-mark hold ${NV_CUDNN_PACKAGE_NAME} \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.8 and related packages
RUN apt-get -y update \
    && apt-get install -y software-properties-common \
    && apt-get -y update \
    && add-apt-repository universe \
    && apt-get -y update \ 
    && apt-get install -y python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*


# Install Git, GCC and Clang toolchains, and necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
	clang \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /repos/docker_cuda_app
COPY requirements.txt app.py ./
RUN python3  -m pip install --upgrade pip
RUN python3 -m pip install pylint flake8
#RUN pip install -e '.[llvm,testing,cuda,gpu,triton]'
RUN pip install --no-cache-dir -r requirements.txt  --default-timeout=100

# Clone the tinygrad repository from GitHub
RUN git clone https://github.com/tinygrad/tinygrad.git
#    cd ./tinygrad
#    python3 -m pip install -e .

# Set the working directory to the cloned repository
#WORKDIR /repos/docker_cuda_app/tinygrad

#Install from master
#RUN python3 -m pip install git+https://github.com/tinygrad/tinygrad.git

