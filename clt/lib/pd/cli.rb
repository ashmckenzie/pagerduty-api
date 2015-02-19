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
      def execute
        status = [ PD::Status::TRIGGERED ]
        PD::Incidents.where(status: status).acknowledge_all!(interactive: true)
      end
    end

    class ResolveCommand < AbstractCommand
      def execute
        status = [ PD::Status::TRIGGERED, PD::Status::ACKNOWLEDGED ]
        PD::Incidents.where(status: status).resolve_all!(interactive: true)
      end
    end

    class AcknowledgeAllCommand < AbstractCommand
      def execute
        status = [ PD::Status::TRIGGERED ]
        PD::Incidents.where(status: status).acknowledge_all!
      end
    end

    class ResolveAllCommand < AbstractCommand
      def execute
        status = [ PD::Status::TRIGGERED, PD::Status::ACKNOWLEDGED ]
        PD::Incidents.where(status: status).resolve_all!
      end
    end

    class ListNeedingAttentionCommand < AbstractCommand
      option "--all", :flag, "All incidents, not just mine", default: false

      def execute
        status = [ PD::Status::TRIGGERED, PD::Status::ACKNOWLEDGED ]

        options = { status: status }
        options[:user_id] = nil if all?

        incidents = PD::Incidents.where(options)
        puts Formatters::Table.new(incidents).render
      end
    end

    class MainCommand < AbstractCommand
      subcommand 'console', 'Run a console', ConsoleCommand
      subcommand 'list', 'List incidents needing attention (triggered + acknowledged)', ListNeedingAttentionCommand
      subcommand 'ack', 'Acknowledge Interactively (mine)', AcknowledgeCommand
      subcommand 'resolve', 'Resolve interactively (mine)', ResolveCommand
      subcommand 'ack-all', 'Acknowledge all (mine)', AcknowledgeAllCommand
      subcommand 'resolve-all', 'Resolve all (mine)', ResolveAllCommand
    end
  end
end
