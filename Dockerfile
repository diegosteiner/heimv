### === base === ###                 
FROM ruby:2.7.0-alpine AS base
FROM base AS development
RUN apk add --update build-base \
  linux-headers \
  git \
  postgresql-dev \        
  nodejs \             
  yarn \
  less \                                                                       
  curl \
  tzdata
                                       
ARG UID=1001
ARG GID=1001
RUN mkdir -p /app
RUN addgroup -S app -g $GID && adduser -S -u $UID -G app -D app && chown -R $UID:$GID /app || true
USER $UID
WORKDIR /app

RUN gem install bundler solargraph
RUN bundle config path /app/vendor/bundle

### === build === ###                                                                                                                                 [0/
FROM development AS build                                                      
                                       
ENV RAILS_ENV=production               
ENV NODE_ENV=production   
ENV BUNDLE_WITHOUT="test development"
                                       
COPY --chown=app . /app     

RUN bundle install && bundle clean && bundle package
RUN yarn install              

RUN bin/webpack
RUN rm -rf /app/node_modules/* 
                                       
### === production === ###
FROM base AS production
                                       
RUN apk add --no-cache --update postgresql-dev tzdata                          
RUN mkdir -p /app && adduser -D app && chown -R app /app
USER app    
WORKDIR /app                                                              

ENV GEM_HOME=/app/vendor/bundle
ENV BUNDLE_PATH=${BUNDLE_PATH}
ENV BUNDLE_WITHOUT="test development"
RUN gem install bundler 
                                       
COPY --chown=app --from=build /app /app                              
RUN bundle install --local
                                       
ENV RAILS_ENV=production               
ENV NODE_ENV=production 
ENV RAILS_LOG_TO_STDOUT="true"  
ENV PORT=3000

CMD ["bin/rails", "s", "-b", "0.0.0.0"] 
