# =========================================================
# PocketPal multi-stage production Dockerfile
# =========================================================
#
# Targets:
#   frontend-run - serves the compiled React application
#   backend-run  - runs the Express API
#
# npm is used during image construction but removed from the
# final runtime images to reduce vulnerabilities and attack surface.
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

# Copy the frontend source after installing dependencies.
COPY . .

# An empty API URL causes the frontend to call relative /api routes
# through the Application Load Balancer.
ARG VITE_API_URL=""
ENV VITE_API_URL=$VITE_API_URL

RUN npm run build


# =========================================================
# STAGE 2: RUN FRONTEND
# =========================================================

FROM node:20-alpine AS frontend-run

WORKDIR /app

# Install only the static-file server required at runtime.
#
# npm is then removed because the running frontend does not need a
# package manager. Removing npm also removes vulnerable packages
# bundled inside npm, including brace-expansion and node-tar.
RUN npm install --global serve@14.2.6 \
    && npm cache clean --force \
    && rm -rf /root/.npm \
    && rm -rf /usr/local/lib/node_modules/npm \
    && rm -f /usr/local/bin/npm \
    && rm -f /usr/local/bin/npx

# Copy only the compiled Vite output.
COPY --from=frontend-build /app/dist ./dist

# Ensure the compiled files can be read by the unprivileged user.
RUN chown -R node:node /app

USER node

EXPOSE 5173

CMD ["serve", "-s", "dist", "-l", "5173"]


# =========================================================
# STAGE 3: RUN BACKEND
# =========================================================

FROM node:20-alpine AS backend-run

WORKDIR /app/server

# Copy backend dependency manifests first.
COPY server/package.json server/package-lock.json ./

# Install production dependencies only.
#
# npm is removed after installation because the backend starts
# directly with Node and does not require npm at runtime.
RUN npm ci --omit=dev \
    && npm cache clean --force \
    && rm -rf /root/.npm \
    && rm -rf /usr/local/lib/node_modules/npm \
    && rm -f /usr/local/bin/npm \
    && rm -f /usr/local/bin/npx

# Copy the backend source code.
COPY server ./

RUN chown -R node:node /app/server

USER node

EXPOSE 5000

# Start the API directly with Node instead of `npm start`.
CMD ["node", "index.js"]