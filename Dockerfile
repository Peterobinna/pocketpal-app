# =========================================================
# PocketPal multi-stage production Dockerfile
# =========================================================
#
# Targets:
#   frontend-run - serves compiled React files with Nginx
#   backend-run  - runs the Express API with Node.js
#
# The frontend runtime contains no Node.js, npm or serve package.
# This reduces image size and removes unnecessary dependencies.
# =========================================================


# =========================================================
# STAGE 1: BUILD FRONTEND
# =========================================================

FROM node:20-alpine AS frontend-build

WORKDIR /app

# Copy dependency manifests first for deterministic installation
# and efficient Docker layer caching.
COPY package.json package-lock.json ./

RUN npm ci

# Copy the application source after dependencies are installed.
COPY . .

# An empty value makes the frontend call relative /api routes
# through the AWS Application Load Balancer.
ARG VITE_API_URL=""
ENV VITE_API_URL=$VITE_API_URL

RUN npm run build


# =========================================================
# STAGE 2: RUN FRONTEND WITH UNPRIVILEGED NGINX
# =========================================================

FROM nginxinc/nginx-unprivileged:alpine AS frontend-run

# Temporarily become root only while applying operating-system
# security patches and preparing configuration files.
USER root

# Upgrade Alpine packages to patched versions, including
# libcrypto3 and libssl3.
RUN apk upgrade --no-cache

# Remove the default Nginx virtual-host configuration.
RUN rm -f /etc/nginx/conf.d/default.conf

# Install the PocketPal Nginx configuration.
COPY --chown=101:101 nginx.conf /etc/nginx/conf.d/pocketpal.conf

# Copy only compiled static frontend files.
COPY --from=frontend-build --chown=101:101 /app/dist /usr/share/nginx/html

# Return to the image's unprivileged Nginx user.
USER 101

EXPOSE 5173

CMD ["nginx", "-g", "daemon off;"]


# =========================================================
# STAGE 3: RUN BACKEND
# =========================================================

FROM node:20-alpine AS backend-run

WORKDIR /app/server

# Apply current Alpine security patches, including patched
# OpenSSL packages.
RUN apk upgrade --no-cache

# Copy dependency manifests before source files.
COPY server/package.json server/package-lock.json ./

# Install production dependencies only. npm is removed afterward
# because the backend starts directly with Node.js.
RUN npm ci --omit=dev \
    && npm cache clean --force \
    && rm -rf /root/.npm \
    && rm -rf /usr/local/lib/node_modules/npm \
    && rm -f /usr/local/bin/npm \
    && rm -f /usr/local/bin/npx

COPY server ./

RUN chown -R node:node /app/server

USER node

EXPOSE 5000

CMD ["node", "index.js"]