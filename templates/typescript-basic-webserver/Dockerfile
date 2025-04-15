# filename: templates/typescript-basic-webserver/Dockerfile
# This Dockerfile is for a simple typescript web application

FROM node:20-slim

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

RUN npm run build

EXPOSE 3000
CMD ["node", "dist/index.js"]
