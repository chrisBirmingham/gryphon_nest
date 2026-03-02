# frozen_literal_string: true

require 'optparse'

module Gryphon
  class Cli
    COMMANDS = %w[
      build
      clean
      serve
    ].freeze

    def run
      options = {
        compress: false,
        force: false,
        port: 8000,
        watch: false
      }

      parse!(options)
      execute(ARGV[0], options)
    rescue OptionParser::ParseError => e
      usage_error(e.message)
    rescue Errors::GryphonError => e
      warn e.message
      exit false
    end

    private

    # @param command [String]
    # @param options [Hash]
    # @raise [OptionParser::ParseError]
    def execute(command, options)
      raise OptionParser::ParseError, "Unknown command #{command}" unless COMMANDS.include?(command)

      nest = Gryphon::Nest.new(
        Processors.create,
        options[:compress] ? Compressors.create : [],
        options[:force]
      )

      if command == 'clean'
        nest.clean
      else
        nest.build

        nest.serve(options[:port], options[:watch]) if command == 'serve'
      end
    end

    # @param options [Hash]
    # @raise [OptionParser::ParseError]
    def parse!(options)
      OptionParser.new do |opts|
        opts.banner = 'Usage: gryphon [build|serve|clean] [options]
Yet another static website builder using mustache and sass'

        opts.separator ''

        opts.on('-c', '--compress', 'Create compressed versions of each file')

        opts.on('-f', '--force', 'Force (re)build all files')

        opts.on('-p', '--port [PORT]', Integer, 'Port to run dev server on')

        opts.on('-w', '--watch', 'Watch for file changes when running the local server')

        opts.on('-h', '--help', 'Show this message') do
          puts opts
          exit
        end

        opts.on('-v', '--version', 'Print version') do
          puts Gryphon::VERSION
          exit
        end
      end.parse!(into: options)
    end

    # @param msg [String]
    def usage_error(msg)
      warn "gryphon: #{msg}
Try 'gryphon -h' for more information"
      exit false
    end
  end
end
