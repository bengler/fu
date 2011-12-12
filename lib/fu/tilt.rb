# Makes Fu available through Tilt, also contains a utility
# function that will be added to Sinatra if Sinatra is 
# defined.
require 'fu'
require 'tilt'
require 'mustache'

module Tilt
  class FuTemplate < Template
    self.default_mime_type = "text/html"
    def initialize_engine
      return if defined? ::Fu
      require_template_library 'fu'
    end

    def prepare; end

    def evaluate(scope, locals, &block)      
      Mustache.render(Fu.to_mustache(data), locals.merge(scope.is_a?(Hash) ? scope : {}).merge({:yield => block.nil? ? '' : block.call}))
    end
  end
  register FuTemplate, 'fu'
end

if defined?(Sinatra)
  module Sinatra::Templates
    def fu(template, options={}, locals={})
      render :fu, template, options, locals
    end
  end
end