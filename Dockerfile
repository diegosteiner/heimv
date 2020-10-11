### === base === ###                 
FROM ruby:2.7.2-alpine AS base
RUN apk add --no-cache --update postgresql-dev tzdata nodejs
RUN gem install bundler

RUN mkdir -p /app
WORKDIR /app

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

RUN bundle config path /app/vendor/bundle && \
    bundle config cache --all true

### === build === ###                                                                                                                                 [0/
FROM development AS build                                                      

ENV RAILS_ENV=production               
ENV NODE_ENV=production   

COPY --chown=app . /app     

RUN bundle config without test:development && \
    bundle install && \
    bundle clean && \
    bundle package
RUN yarn install              

RUN bin/webpack
RUN rm -rf /app/node_modules/* 

### === production === ###
FROM base AS production

RUN gem install bundler 
RUN mkdir -p /app && \
        adduser -D app && \
    chown -R app /app
USER app    
WORKDIR /app                                                              

RUN bundle config path /app/vendor/bundle && \
    bundle config deployment true && \
    bundle config without test:development

COPY --chown=app --from=build /app /app                              
RUN bundle install --local

ENV RAILS_ENV=production               
ENV NODE_ENV=production 
ENV RAILS_LOG_TO_STDOUT="true"  
ENV PORT=3000

CMD ["bin/rails", "s", "-b", "0.0.0.0"] 
