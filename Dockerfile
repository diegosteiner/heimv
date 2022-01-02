### === base === ###                 
FROM ruby:3.0.3-alpine AS base
RUN apk add --no-cache --update postgresql-dev tzdata nodejs
RUN adduser -D developer
RUN gem install bundler
# ENV PYTHON=/usr/bin/python3

### === development === ###                 
FROM base AS development
RUN apk add --update build-base \
    python3 \
    linux-headers \
    git \
    yarn \
    less \
    curl \
    gnupg

RUN gem install solargraph standardrb ruby-debug-ide debase rufo

ENV BUNDLE_CACHE_ALL=true
ENV BUNDLE_PATH=/home/developer/.bundle
USER developer
RUN mkdir -p /home/developer/app && \
    mkdir -p /home/developer/app/vendor && \
    mkdir -p /home/developer/app/node_modules
WORKDIR /home/developer/app

### === build === ### 
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
