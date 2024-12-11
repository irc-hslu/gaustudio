# Base image with PyTorch, CUDA 12.4, and cuDNN 9
FROM nvidia/cuda:12.6.3-devel-ubuntu20.04

# Set environment variables for Python
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    git \
    gcc \
    curl \
    cmake \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libtbb-dev \
    libtiff-dev \
    libjpeg-dev \
    libpng-dev \
    libxext6 \
    libxrender-dev \
    libgl1-mesa-glx \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y python3.9 python3.9-distutils python3.9-dev python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3.9 -m pip install --upgrade pip

ARG TORCH_CUDA_ARCH_LIST="8.0 8.6 8.7 8.9"

# Set Python 3.8 as the default Python version
RUN ln -sf /usr/bin/python3.9 /usr/bin/python && \
    ln -sf /usr/bin/python3.9 /usr/bin/python3

# Install Python dependencies
COPY . /opt/gaustudio
RUN --mount=type=cache,target=/root/.cache/pip pip install --upgrade pip && pip install -r /opt/gaustudio/requirements.txt

# Install mvs-texturing
RUN git clone https://github.com/nmoehrle/mvs-texturing.git /tmp/mvs-texturing
RUN cd /tmp/mvs-texturing && mkdir build && cd build && cmake .. && make -j
RUN cp /tmp/mvs-texturing/build/apps/texrecon/texrecon /usr/local/bin/ && rm -rf /tmp/mvs-texturing


# Install GauStudio rasterizer and framework
RUN cd /opt/gaustudio/submodules/gaustudio-diff-gaussian-rasterization && python setup.py install 
RUN cd /opt/gaustudio/ && pip install -e .

# Optional: Install PyTorch3D (commented as per instructions)
# RUN pip install git+https://github.com/facebookresearch/pytorch3d.git

# Set the entrypoint to bash for flexibility
CMD ["bash"]
