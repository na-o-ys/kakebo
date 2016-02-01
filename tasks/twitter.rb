require_relative '../lib/kakebo.rb'

Kakebo::DataSource::Twitter
  .new(Kakebo::Config['twitter'])
  .run
