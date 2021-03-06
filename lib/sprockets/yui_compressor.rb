require 'yui/compressor'

module Sprockets
  # Public: YUI compressor.
  #
  # To accept the default options
  #
  #     environment.register_bundle_processor 'application/javascript',
  #       Sprockets::YUICompressor
  #
  # Or to pass options to the YUI::JavaScriptCompressor class.
  #
  #     environment.register_bundle_processor 'application/javascript',
  #       Sprockets::YUICompressor.new(munge: true)
  #
  class YUICompressor
    VERSION = '1'

    # Public: Return singleton instance with default options.
    #
    # Returns YUICompressor object.
    def self.instance
      @instance ||= new
    end

    def self.call(input)
      instance.call(input)
    end

    def initialize(options = {})
      @options = options
      @cache_key = [
        self.class.name,
        ::YUI::Compressor::VERSION,
        VERSION,
        options
      ].freeze
    end

    def call(input)
      data = input[:data]

      case input[:content_type]
      when 'application/javascript'
        key = @cache_key + [input[:content_type], input[:data]]
        input[:cache].fetch(key) do
          ::YUI::JavaScriptCompressor.new(@options).compress(data)
        end
      when 'text/css'
        key = @cache_key + [input[:content_type], input[:data]]
        input[:cache].fetch(key) do
          ::YUI::CssCompressor.new(@options).compress(data)
        end
      else
        data
      end
    end
  end
end
