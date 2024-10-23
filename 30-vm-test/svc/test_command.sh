#!/bin/bash
curl -X POST \
  -d '{ "my_key": 42 }' \
  -H "Content-Type: application/json" \
  http://localhost:3000/echo
