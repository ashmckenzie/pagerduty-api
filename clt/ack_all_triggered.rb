#!/usr/bin/env ruby

require 'logger'
require_relative './library'

if ENV['DEBUG']
  require 'pry'
  require 'pry-byebug'
end

logger = Logger.new($stdout)
logger.level = Logger::INFO

incidents = PagerDutyAPI::Incidents.new

# incidents.filter('triggered').each do |incident|
incidents.filter('acknowledged').each do |incident|
  logger.info "Ack'ng #{incident.inspect}"
  # incident.ack!
end
