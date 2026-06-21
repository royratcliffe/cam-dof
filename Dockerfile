FROM alpine:latest
RUN apk --no-cache add swi-prolog --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main
RUN swipl pack install --global -y --branch patch-1 https://github.com/royratcliffe/sysfs.git \
 && rm -rf /usr/local/share/swi-prolog/pack/Downloads/*
COPY *.pl /srv/
WORKDIR /srv
# Quietly compile the Prolog files and remove the source files to save
# space; the compiled files will be used at runtime.
RUN for pl in *.pl; do swipl -q -t "qcompile('$pl')"; done; rm *.pl
ENTRYPOINT ["swipl", "-s", "cam_dof"]
