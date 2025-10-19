# renovate: datasource=docker depName=intel/oneapi
ARG ONEAPI_VERSION=2025.2.2-0-devel-ubuntu24.04

FROM intel/oneapi:${ONEAPI_VERSION}

# renovate: datasource=github-tags depName=ggerganov/whisper.cpp
ARG WHISPER_CPP_VERSION=v1.8.2

WORKDIR /app

RUN git clone --branch ${WHISPER_CPP_VERSION} https://github.com/ggerganov/whisper.cpp.git . && \
    cmake -B build -DGGML_SYCL=ON -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DGGML_SYCL_F16=ON && \
    cmake --build build -j --config Release

ENTRYPOINT [ "build/bin/whisper-server" ]