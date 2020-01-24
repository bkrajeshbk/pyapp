#!/bin/bash
#

# Ensure pyapp-docker-service service is running
SERVICES=$(docker service ls --filter name=pyapp-docker-service --quiet | wc -l)
if [[ "$SERVICES" -eq 0 ]]; then
    docker service create \
        --image pyapp-docker-image:latest \
        --name pyapp-docker-service \
        --network my-net \
        --restart-condition any \
        --restart-delay 5s \
        --update-delay 10s \
        --update-parallelism 1
else
    docker service update \
        --image pyapp-docker-image:latest \
        --name pyapp-docker-service
fi