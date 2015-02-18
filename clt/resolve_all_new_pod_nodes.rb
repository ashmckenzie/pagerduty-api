#!/usr/bin/env ruby

require_relative './library'

incidents = PagerDutyAPI::Incidents.new

incidents.filter('acknowledged').each do |incident|
  p incident
  binding.pry
end
