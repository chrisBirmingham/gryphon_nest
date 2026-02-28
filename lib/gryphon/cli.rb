# frozen_literal_string: true

require 'optparse'

module Gryphon
  class Cli
    COMMANDS = %w[build clean serve]

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
    end

    private

    def execute(command, options)
      raise OptionParser::ParseError, "Unknown command #{command}" unless COMMANDS.include?(command)

      nest = Gryphon::Nest.new(options[:compress], options[:force])

      case command
      when 'clean'
        nest.clean
      when 'build'
        nest.build
      when 'serve'
        nest.build

        nest.watch if options[:watch]

        nest.serve(options[:port])
      end
    end

    def parse!(options)
      OptionParser.new do |opts|
        opts.banner = 'Usage: nest [build|serve|clean] [options]
Yet another static website builder using mustache and sass'

        opts.separator ''

        opts.on('-c', '--compress', 'Create gzipped compressed versions of each file')

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
      warn "gryphon: #{msg}"
      warn "Try 'gryphon -h' for more information"
      exit(1)
    end
  end
end
