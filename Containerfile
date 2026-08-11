FROM ghcr.io/containerpak/gtk:main

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends kooha && \
    cpak-clean-junk
