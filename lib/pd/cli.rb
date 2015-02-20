require 'clamp'
require 'highline/import'

module PD
  class CLI < Clamp::Command

    class AbstractCommand < Clamp::Command
      option [ '-c', '--config_file' ], 'CONFIG', 'config file'

      option '--version', :flag, 'show version' do
        puts PD::VERSION
        exit(0)
      end
    end

    class ConsoleCommand < AbstractCommand
      def execute
        require 'pry-byebug'
        pry PD
      end
    end

    class AcknowledgeCommand < AbstractCommand
      option "--everyone", :flag, "ALL incidents, not just mine", default: false
      option "--non-interactive", :flag, "Non-interactively acknowledge", default: false

      def execute
        status = [ Status::TRIGGERED ]

        options = { status: status }
        options[:user_id] = nil if everyone?
        PD::Incidents.new.where(options).acknowledge_all!(interactive: !non_interactive?)
      end
    end

    class ResolveCommand < AbstractCommand
      option "--everyone", :flag, "All incidents, not just mine", default: false
      option "--non-interactive", :flag, "Non-interactively acknowledge", default: false

      def execute
        status = [ Status::TRIGGERED, Status::ACKNOWLEDGED, Status::RESOLVED ]
        options = { status: status }
        options[:user_id] = nil if everyone?
        PD::Incidents.new.where(options).resolve_all!(interactive: !non_interactive?)
      end
    end

    class ListNeedingAttentionCommand < AbstractCommand
      option "--everyone", :flag, "All incidents, not just mine", default: false

      def execute
        status = [ Status::TRIGGERED, Status::ACKNOWLEDGED ]

        options = { status: status }
        options[:user_id] = nil if everyone?

        incidents = PD::Incidents.new.where(options)
        table = Formatters::Table.new(incidents).render
        puts table if table
      end
    end

    class MainCommand < AbstractCommand
      subcommand 'console', 'Run a console', ConsoleCommand
      subcommand 'list', 'List incidents needing attention (triggered + acknowledged)', ListNeedingAttentionCommand
      subcommand [ 'ack', 'acknowledge' ], 'Acknowledge incidents', AcknowledgeCommand
      subcommand 'resolve', 'Resolve incidents', ResolveCommand
    end
  end
end
