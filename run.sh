#!/bin/bash

docker                                                    \
  run                                                     \
  --entrypoint /bin/bash                                  \
  --name ops-ms                                           \
  --hostname ops-ms                                       \
  --rm                                                    \
  -e BWS_ACCESS_TOKEN=nope                                \
  -e LIB_VERSION=0.4.0                                    \
  -e MANAGEMENT=true                                      \
  -e WORKER=true                                          \
  -it                                                     \
  -p 80:80                                                \
  -v ${HOME}/configurations:/etc/927/configurations       \
  927technology/ops:latest

