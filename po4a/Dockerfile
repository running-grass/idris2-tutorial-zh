FROM ubuntu:25.04

RUN apt-get update && apt-get install -y po4a

WORKDIR /work

ENTRYPOINT ["/work/po4a/po4a-update.sh"]