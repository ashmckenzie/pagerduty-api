require 'pry'
require 'pry-byebug'

require 'dotenv'
require 'singleton'
require 'hashie'

module PagerDutyAPI
  class Config

    include Singleton

    def self.settings()  instance.settings; end

    def initialize
      Dotenv.load('../.env', '../.env_development')
    end

    def settings
      @settings ||= begin
        Hashie::Mash.new(
          {
            account: {
              name:   ENV['PAGERDUTY_ACCOUNT_NAME']   || raise("Missing ENV['PAGERDUTY_ACCOUNT_NAME'], add to .env.development or .env"),
              token:  ENV['PAGERDUTY_ACCOUNT_TOKEN']  || raise("Missing ENV['PAGERDUTY_ACCOUNT_TOKEN'], add to .env.development or .env")
            },

            incidents_for_user_id:  ENV['PAGERDUTY_ACCOUNT_INCIDENTS_FOR_USER_ID'],
            sleep_for:              ENV['PAGERDUTY_NOTIFICATION_SLEEP_FOR'] || 10
          }
        )
      end
    end
  end
end

require 'pager_duty/connection'

module PagerDutyAPI
  class Incidents

    def initialize publisher
      @publisher = publisher
      @seen_incidents = []
    end

    def poll
      while true do
        response          = pagerduty.get('incidents', fields: 'id,created_on,html_url,trigger_summary_data,assigned_to_user', assigned_to_user: settings.incidents_for_user_id, status: 'triggered,acknowledged')
        unseen_incidents  = response.incidents.reject { |x| seen_incidents.include?(x.id) }

        unless unseen_incidents.empty?
          unseen_incidents.each do |incident|
            seen_incidents << incident.id
            publisher.tell_the_world!(PagerDutyAPI::SSE.new('incident', incident, incident['created_on'].to_i))
          end
        else
          publisher.tell_the_world!(PagerDutyAPI::SSE.new('ping', {}))
        end

        sleep(settings.sleep_for)
      end
    end

    private

      attr_accessor :publisher, :seen_incidents

      def settings
        @settings ||= Config.settings
      end

      def pagerduty
        @pagerduty ||= PagerDuty::Connection.new(settings.account.name, settings.account.token)
      end
  end
end

require 'wisper'

module PagerDutyAPI
  class IncidentPublisher

    include Wisper::Publisher

    def tell_the_world! sse
      puts sse.inspect
      broadcast(:event, sse)
    end

  end
end

require 'json'

module PagerDutyAPI
  class SSE

    def initialize channel, data, timestamp=Time.now.to_i
      @channel   = "pagerduty:#{channel}"
      @data      = data
      @timestamp = timestamp
    end

    def serialised
      {
        timestamp:  timestamp,
        data:       data
      }
    end

    def inspect
      "timestamp=[#{timestamp}], channel=[#{channel}], data=[#{data.inspect}]"
    end

    def to_s
      "event: %s\ndata: %s\n\n" % [ channel, serialised.to_json ]
    end

    private

      attr_reader :channel, :data, :timestamp
  end
end

require 'sinatra/base'
require 'sinatra/streaming'

class WebApp < Sinatra::Base

  configure do
    mime_type :event_stream, 'text/event-stream'
  end

  helpers Sinatra::Streaming

  get '/subscribe', provides: :event_stream do
    headers(
      'Content'                     => 'keep-alive',
      'Access-Control-Allow-Origin' => '*'
    )

    stream(:keep_open) do |out|
      $incidents_publisher.on(:event) do |sse|
        out << sse.to_s unless out.closed?
      end
    end

  end

end
