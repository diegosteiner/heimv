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

ENV BUNDLE_PATH=/app/vendor/bundle
ENV BUNDLE_CACHE_PATH=/app/vendor/cache
RUN gem install bundler 

### === build === ###                                                                                                                                 [0/2749]
FROM development AS build                                                      
                                       
ENV RAILS_ENV=production               
ENV NODE_ENV=production   
ENV BUNDLE_WITHOUT="test development"
                                       
COPY --chown=app Gemfile /app/    
COPY --chown=app Gemfile.lock /app/                                       
RUN mkdir -p ${BUNDLE_CACHE_PATH}
COPY --chown=app vendor/cache ${BUNDLE_CACHE_PATH}
RUN bundle install
                                       
COPY --chown=app package.json /app/        
COPY --chown=app yarn.lock /app/
COPY --chown=app node_modules /app/node_modules
RUN yarn install              
                                       
COPY --chown=app . /app     
RUN bin/webpack
RUN rm -rf /app/node_modules/* /app/vendor/cache
                                       
### === production === ###
FROM base AS production
                                       
RUN apk add --no-cache --update postgresql-dev tzdata                          
RUN mkdir -p /app && adduser -D app && chown -R app /app
USER app    
WORKDIR /app                                                              

ENV BUNDLE_PATH=/app/vendor/bundle
ENV BUNDLE_WITHOUT="test development"
RUN gem install bundler 
                                       
COPY --chown=app --from=build /app /app                              
RUN bundle install
                                       
ENV RAILS_ENV=production               
ENV NODE_ENV=production 
ENV RAILS_LOG_TO_STDOUT="true"  
ENV PORT=3000

CMD ["bin/rails", "s", "-b", "0.0.0.0"] 
