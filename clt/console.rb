#!/usr/bin/env ruby

require_relative './library'

require 'pry'
require 'pry-byebug'

include PagerDutyAPI

pry
# Incidents.where(status: 'acknowledged').acknowledge_all!
