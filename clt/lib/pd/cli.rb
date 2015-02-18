require 'clamp'

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

    class MainCommand < AbstractCommand
      subcommand 'console', 'Run a console', ConsoleCommand
      subcommand 'ack-all', 'Acknowledge all', AcknowledgeAllCommand
      subcommand 'resolve-all', 'Resolve all', ResolveAllCommand
    end
  end
end
