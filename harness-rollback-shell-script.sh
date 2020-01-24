#!/bin/bash
#

# When pyapp-docker-service service is fails to update
docker service rollback \
    --name pyapp-docker-service