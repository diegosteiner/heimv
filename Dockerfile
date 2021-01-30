### === base === ###                 
FROM ruby:2.7.2-alpine AS base
RUN apk add --no-cache --update postgresql-dev tzdata nodejs
RUN mkdir -p /app && \
    mkdir -p /app/vendor && \
    mkdir -p /app/node_modules
WORKDIR /app
RUN gem install bundler

ENV BUNDLE_CACHE_ALL=true
ENV BUNDLE_PATH=/app/vendor/bundle

### === development === ###                 
FROM base AS development
RUN apk add --update build-base \
    linux-headers \
    git \
    yarn \
    less \
    curl \
    gnupg \
    python3

RUN gem install solargraph standardrb ruby-debug-ide debase

ARG UID=1001
ARG GID=1001
RUN addgroup -S app -g $GID && \ 
    adduser -S -u $UID -G app -D app && \
    chown -R app:app /app && \
    chown -R app:app /usr/local/bundle || true
USER $UID

### === build === ###                                                                                                                                 [0/
FROM development AS build                                                      

ENV RAILS_ENV=production               
ENV NODE_ENV=production   
ENV BUNDLE_WITHOUT="test:development"


COPY --chown=app . /app     

RUN bundle install && \
    bundle clean && \
    bundle package
RUN yarn install              

RUN bin/webpack

### === production === ###
FROM base AS production

RUN adduser -D app && \
    chown -R app /app
USER app    

ENV BUNDLE_WITHOUT="test:development"
ENV BUNDLE_DEPLOYMENT="true"

COPY --chown=app --from=build /app /app                              
RUN rm -rf /app/node_modules/* 
RUN bundle install --local

ENV RAILS_ENV=production               
ENV NODE_ENV=production 
ENV RAILS_LOG_TO_STDOUT="true"  
ENV PORT=3000

CMD ["bin/rails", "s", "-b", "0.0.0.0"] 
