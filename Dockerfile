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
  bash \ 
  curl \
  tzdata
                                       
ARG UID=1000      
ARG GID=1000
RUN addgroup -S app -g $GID && adduser -S -u $UID -G app -D app
RUN mkdir -p /app && chown -R $UID:$GID /app
USER app
WORKDIR /app

ENV BUNDLE_PATH=/app/vendor/bundle
RUN gem install bundler 

### === build === ###                                                                                                                                 [0/2749]
FROM development AS build                                                      
                                       
ENV RAILS_ENV=production               
ENV NODE_ENV=production   
                                       
COPY --chown=app Gemfile /app/    
COPY --chown=app Gemfile.lock /app/                                       
RUN bundle install --without=test --without=development 
                                       
COPY --chown=app package.json /app/        
COPY --chown=app yarn.lock /app/
RUN yarn install              
                                       
COPY --chown=app . /app     
RUN bin/webpack  
                                       
### === production === ###
FROM base AS production
                                       
RUN apk add --no-cache --update postgresql-dev tzdata                          
RUN adduser -D app
RUN mkdir -p /app && chown -R app /app
USER app    
WORKDIR /app                                                              

ENV BUNDLE_PATH=/app/vendor/bundle
RUN gem install bundler 
                                       
COPY --chown=app --from=build /app /app                              
RUN bundle install --without=test --without=development                        
                                       
ENV RAILS_ENV=production               
ENV NODE_ENV=production 
ENV RAILS_LOG_TO_STDOUT="true"  
ENV PORT=3000

CMD ["bin/rails", "s",  "-b", "0.0.0.0"] 