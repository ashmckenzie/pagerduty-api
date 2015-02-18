require 'clamp'
require 'terminal-table'

module PD
  class CLI < Clamp::Command

    class AbstractCommand < Clamp::Command
      option [ '-c', '--config_file' ], 'CONFIG', 'config file'

      option '--version', :flag, 'show version' do
        puts PD::VERSION
        exit(0)
      end

      def containers
        @containers ||= Containers.new
      end
    end

    class ConsoleCommand < AbstractCommand
      def execute
        require 'pry-byebug'
        pry
      end
    end

    class AcknowledgeAllCommand < AbstractCommand
      def execute
        PD::Incidents.where(status: %W( #{PD::Status::TRIGGERED} )).acknowledge_all!
      end
    end

    class ResolveAllCommand < AbstractCommand
      def execute
        PD::Incidents.where(status: %W( #{PD::Status::TRIGGERED} #{PD::Status::ACKNOWLEDGED} )).resolve_all!
      end
    end

    class ListNeedingAttentionCommand < AbstractCommand
      option "--all", :flag, "All incidents, not just mine", default: false

      def execute
        headings = [
          '#',
          'Node',
          'Assigned To',
          'Detail',
          'URL'
        ]

        options = { status: %W( #{Status::TRIGGERED} #{Status::ACKNOWLEDGED} ) }
        options[:user_id] = nil if all?

        incidents = PD::Incidents.where(options)

        incident_rows = incidents.map do |incident|
          [
            incident.id,
            incident.node.name,
            incident.user.name,
            incident.detail,
            incident.link
          ]
        end

        puts Terminal::Table.new(headings: headings, rows: incident_rows) unless incident_rows.empty?
      end
    end

    class MainCommand < AbstractCommand
      subcommand 'console', 'Run a console', ConsoleCommand
      subcommand 'list', 'List all needing attention (triggered + acknowledged)', ListNeedingAttentionCommand
      subcommand 'ack-all', 'Acknowledge all', AcknowledgeAllCommand
      subcommand 'resolve-all', 'Resolve all', ResolveAllCommand
    end
  end
end
