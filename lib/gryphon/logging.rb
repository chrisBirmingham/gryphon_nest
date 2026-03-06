# frozen_string_literal: true

require 'logger'

module Gryphon
  module Logging
    include Kernel

    # @param msg [String]
    # @param lvl [Integer]
    def log(msg, lvl = Logger::INFO)
      @logger ||= create
      @logger.add(lvl, msg)
    end

    private

    # @return [Logger]
    def create
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
