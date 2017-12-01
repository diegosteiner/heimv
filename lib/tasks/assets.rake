namespace :assets do
  task precompile: :environment do
    Rake::Task['webpacker:compile'].invoke
  end

  task clean: :environment do
  end

end
