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
    rescue Errors::GryphonError => e
      warn e.message
      exit false
    end

    private

    # @param command [String]
    # @param options [Hash]
    # @raise [Errors::GryphonError]
    def execute(command, options)
      raise Errors::GryphonError, to_usage_error("Unknown command #{command}") unless COMMANDS.include?(command)

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
    # @raise [Errors::GryphonError]
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
    rescue OptionParser::ParseError => e
      raise Errors::GryphonError, to_usage_error(e.message)
    end

    # @param msg [String]
    # @return [String]
    def to_usage_error(msg) =
      "gryphon: #{msg}\nTry 'gryphon -h' for more information"
  end
end
