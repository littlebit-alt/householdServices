#!/usr/bin/env bash

npm install --include=dev

chmod +x ./node_modules/.bin/prisma

npx prisma generate