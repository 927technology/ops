#!/bin/bash

docker                                                    \
  run                                                     \
  --entrypoint /bin/bash                                  \
  --name ops-ms                                           \
  --hostname ops-ms                                       \
  --rm                                                    \
  -e LIB_VERSION=0.4.0                                    \
  -e MANAGEMENT=true                                      \
  -e WORKER=true                                          \
  -it                                                     \
  -p 80:80                                                \
  -v ${HOME}/configurations:/etc/927/configurations       \
  -v ${HOME}/secrets:/var/mod_gearman/secrets/            \
  -v ${HOME}/.oci:/var/mod_gearman/.oci                   \
  927technology/ops:latest
