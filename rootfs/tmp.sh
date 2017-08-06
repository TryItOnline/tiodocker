tiolang=05ab1e
docker run -d --name tiomin --add-host arena:127.0.0.1 tryitonline/tiomin
docker exec -it tiomin /bin/bash -c "tiopull -l $tiolang"
docker exec -it tiomin /bin/bash -c 'while ! timeout 1 bash -c "echo > /dev/tcp/localhost/22"; do sleep 1; done'
docker exec -it tiomin /bin/bash -c "tiodryrun -l $tiolang"
docker container rm tiomin -f
