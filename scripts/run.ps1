#!/usr/bin/env pwsh
param (
    $command
)

if (-not $command)  {
    $command = "start"
}

$ProjectRoot = "${PSScriptRoot}/.."

$env:AMBULANCE_API_ENVIRONMENT="Development"
$env:AMBULANCE_API_PORT="8080"
$env:AMBULANCE_API_MONGODB_USERNAME="root"
$env:AMBULANCE_API_MONGODB_PASSWORD="neUhaDnes"

function mongo {
    docker compose --file ${ProjectRoot}/deployments/docker-compose/compose.yaml $args
}

switch ($command) {
    "start" {
        try {
            mongo up --detach
            go run /home/hocikto/wac/ambulance-webapi/cmd/ambulance-api-service
        } finally {
            mongo down
        }
    }
    "openapi" {
        docker run --rm -ti -v /home/hocikto/wac/ambulance-webapi:/local openapitools/openapi-generator-cli generate -c /local/scripts/generator-cfg.yaml
    }
    "test" {
        go test -v ./...
    }
    "mongo" {
        mongo up
    }
    "docker" {
         docker build -t hocikto/ambulance-wl-webapi:local-build -f /home/hocikto/wac/ambulance-webapi/build/docker/Dockerfile .
    }
    default {
        throw "Unknown command: $command"
    }
}