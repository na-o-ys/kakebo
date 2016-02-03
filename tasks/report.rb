require_relative '../lib/kakebo.rb'

Kakebo::Report
  .new(Kakebo::Config['twitter'])
  .report
