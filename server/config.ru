require './web_app'

$incidents_publisher = PagerDutyAPI::IncidentPublisher.new

Thread.new {
  PagerDutyAPI::Incidents.new($incidents_publisher).poll
}

run WebApp
