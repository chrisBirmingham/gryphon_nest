# frozen_string_literal: true

require 'logger'

module GryphonNest
  # Mixing module used for logging messages to the console
  module Logging
    # @param msg [String]
    # @param level [Int]
    def log(msg, level = Logger::INFO)
      @logger ||= create_logger
      @logger.add(level, msg)
    end

    private

    # @return [Logger]
    def create_logger
      logger = Logger.new($stdout)

      # Create formatter that matches WebBricks log messages
      logger.formatter = proc do |severity, datetime, _progname, msg|
        date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
        "[#{date_format}] #{severity.ljust(5)} #{msg}\n"
      end

      logger
    end
  end
end
