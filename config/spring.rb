# frozen_string_literal: true

%w[
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
  app/policies
  app/inputs
  lib
].each { |path| Spring.watch(path) }
