# Step 1: Build stage
FROM node:18 AS build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Step 2: Production server
FROM node:18

# Install serve to serve static files
RUN npm install -g serve

WORKDIR /app
COPY --from=build /app/build ./build

# Expose two ports (4000 and 5000)
EXPOSE 4000 5000

# Serve the app on both ports
CMD ["sh", "-c", "serve -s build -l 4000 & serve -s build -l 5000 && wait"]
