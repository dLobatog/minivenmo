require 'active_record'
require 'rubygems'
require 'yaml'

ENV['VENMO_ENV'] ||= 'development'
dbconfig = YAML::load(File.open('db/database.yaml'))[ENV['VENMO_ENV']]
ActiveRecord::Base.establish_connection(dbconfig)
