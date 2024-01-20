FROM node:20.11 AS base

WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Rebuild the source code only when needed
FROM node:20.11 AS builder
WORKDIR /app
COPY --from=base /app/node_modules ./node_modules
COPY . .

# Disable telemetry
ENV NEXT_TELEMETRY_DISABLED 1
RUN yarn build

# Production image, copy all the files and run next
FROM node:20.11-alpine AS runner
WORKDIR /app

ENV NODE_ENV production
# Production image, copy all the files and run next
ENV NEXT_TELEMETRY_DISABLED 1

EXPOSE 8080
ENV PORT 8080
# set hostname to localhost
ENV HOSTNAME "0.0.0.0"

COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
COPY --from=base /app/node_modules ./node_modules
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next

CMD [ "yarn", "start" ]