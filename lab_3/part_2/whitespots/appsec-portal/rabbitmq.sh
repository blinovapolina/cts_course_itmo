#!/bin/sh
# Purge all data after restart
rm -rf /var/lib/rabbitmq/*
# Start RabbitMQ server in the background and capture its PID
rabbitmq-server &
PID=$!

# Wait for RabbitMQ to fully start up (adjust the sleep duration based on your environment)
sleep 5

# Set policies after RabbitMQ starts
rabbitmqctl set_policy TTL ".*" '{"message-ttl":60000}' --apply-to queues
rabbitmqctl set_policy DLX ".*" '{"dead-letter-exchange":"dlx_exchange"}' --apply-to queues
rabbitmqctl set_policy capped_queues ".*" '{"max-length":1000}' --apply-to queues

# Wait for the RabbitMQ server process (PID) to "finish"
wait $PID