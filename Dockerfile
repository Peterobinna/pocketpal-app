# =========================================================
# PocketPal Dockerfile
# =========================================================
# This Dockerfile uses multiple stages:
#
# 1. frontend-build:
#    Builds the React + TypeScript + Vite frontend.
#
# 2. frontend-run:
#    Serves the built frontend application.
#
# 3. backend-run:
#    Runs the Express backend server.
#
# Docker Compose will later choose which target to build.
# =========================================================


# =========================================================
# STAGE 1: Build the frontend
# =========================================================
# We use a specific Node version for consistency.
FROM node:20-alpine AS frontend-build

# Set working directory inside the container.
WORKDIR /app

# Copy frontend package files first.
# This helps Docker cache dependency installation.
COPY package*.json ./

# Install frontend dependencies.
RUN npm install

# Copy the rest of the frontend source code.
COPY . .

# Allow frontend API URL to be passed during Docker build.
# If no value is passed, it defaults to localhost backend.
# An empty value makes the frontend call /api through the same load balancer.
ARG VITE_API_URL=""
ENV VITE_API_URL=$VITE_API_URL

# Build the production frontend files into the dist folder.
RUN npm run build


# =========================================================
# STAGE 2: Run the frontend
# =========================================================
FROM node:20-alpine AS frontend-run

# Set working directory.
WORKDIR /app

# Install a lightweight static server for serving Vite build files.
RUN npm install -g serve

# Copy only the built frontend files from the previous stage.
COPY --from=frontend-build /app/dist ./dist

# Use the built-in non-root node user for better security.
USER node

# Expose frontend port.
EXPOSE 5173

# Serve the frontend application.
CMD ["serve", "-s", "dist", "-l", "5173"]


# =========================================================
# STAGE 3: Run the backend
# =========================================================
FROM node:20-alpine AS backend-run

# Set backend working directory.
WORKDIR /app/server

# Copy backend package files first for better Docker caching.
COPY server/package*.json ./

# Install only production dependencies for the backend.
RUN npm install --omit=dev

# Copy backend source code.
COPY server ./

# Use the built-in non-root node user for better security.
USER node

# Expose backend port.
EXPOSE 5000

# Start the Express server.
CMD ["npm", "start"]