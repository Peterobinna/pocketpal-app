# =========================================================
# PocketPal multi-stage production Dockerfile
# =========================================================
#
# Targets:
#   frontend-run - serves the compiled React application
#   backend-run  - runs the Express API
#
# The final images contain only the components required
# to run each service.
# =========================================================


# =========================================================
# STAGE 1: BUILD FRONTEND
# =========================================================

FROM node:20-alpine AS frontend-build

WORKDIR /app

# Copy dependency manifests first to improve Docker caching.
COPY package.json package-lock.json ./

# Use the committed lockfile for deterministic CI builds.
RUN npm ci

# Copy the frontend source after dependency installation.
COPY . .

# An empty API URL makes the frontend use relative /api routes
# through the Application Load Balancer.
ARG VITE_API_URL=""
ENV VITE_API_URL=$VITE_API_URL

# Compile the TypeScript and Vite production bundle.
RUN npm run build


# =========================================================
# STAGE 2: RUN FRONTEND
# =========================================================

FROM node:20-alpine AS frontend-run

WORKDIR /app

# Upgrade the npm installation supplied by the base image.
# npm 11.19.0 is compatible with Node 20 and uses a patched
# node-tar dependency instead of the vulnerable tar 7.5.18.
#
# Pin serve to a known version so production builds remain
# deterministic.
RUN npm install --global npm@11.19.0 \
    && npm install --global serve@14.2.6 \
    && npm cache clean --force

# Copy only the compiled frontend files.
COPY --from=frontend-build /app/dist ./dist

# The official Node image includes an unprivileged node user.
USER node

EXPOSE 5173

CMD ["serve", "-s", "dist", "-l", "5173"]


# =========================================================
# STAGE 3: RUN BACKEND
# =========================================================

FROM node:20-alpine AS backend-run

WORKDIR /app/server

# Upgrade npm in the backend runtime image as well. This prevents
# the backend Trivy scan from finding the same vulnerable npm
# node-tar package after the frontend scan passes.
RUN npm install --global npm@11.19.0 \
    && npm cache clean --force

# Copy only the backend dependency manifests initially.
COPY server/package.json server/package-lock.json ./

# Install only the production dependency tree recorded in the lockfile.
RUN npm ci --omit=dev \
    && npm cache clean --force

# Copy the backend application code.
COPY server ./

# Ensure application files are readable by the unprivileged user.
RUN chown -R node:node /app/server

USER node

EXPOSE 5000

CMD ["npm", "start"]