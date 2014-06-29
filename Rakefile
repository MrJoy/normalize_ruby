require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default, :development)
require 'code_counter'

desc "Start a PRY console with the application code loaded."
task :console do
  require 'pry'
  require_relative './lib/normalize'
  binding.pry
end
