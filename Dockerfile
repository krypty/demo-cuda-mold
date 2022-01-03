FROM nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04

# inspired from: https://github.com/rui314/mold/issues/161
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt install -y --no-install-recommends software-properties-common && \
  add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
  TZ=Europe/London apt-get install -y tzdata && \
  apt-get install -y --no-install-recommends build-essential git lld clang-10 cmake libstdc++-10-dev libssl-dev libxxhash-dev zlib1g-dev gdb && \
  apt clean && \
  rm -rf /var/lib/apt/lists/* && \
  ln -s /usr/bin/clang-10 /usr/bin/clang && \
  ln -s /usr/bin/clang++-10 /usr/bin/clang++

RUN git clone https://github.com/rui314/mold.git
WORKDIR mold
RUN git checkout v1.0.1


# For mold to be compiled with debug symbols and have an inspectable backstrace
ENV DEBUG 1

RUN make -j$(nproc)

# For some reason, `make install` does not expose the debug symbols. Copying the binary manually instead...
# RUN make install
RUN cp mold /usr/local/bin/

ADD main.cu /opt/demo/main.cu

WORKDIR /opt/demo
