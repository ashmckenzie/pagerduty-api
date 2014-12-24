require './web_app'

$incidents_publisher = PagerDutAPI::IncidentPublisher.new

Thread.new {
  PagerDutAPI::Incidents.new($incidents_publisher).poll
}

run WebApp
