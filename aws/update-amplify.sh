#!/bin/bash

# Atualiza configuração do Amplify
aws amplify update-app \
  --app-id d31iho7gw23enq \
  --build-spec file://amplify.yml \
  --region us-east-1

# Inicia novo build
aws amplify start-job \
  --app-id d31iho7gw23enq \
  --branch-name main \
  --job-type RELEASE \
  --region us-east-1