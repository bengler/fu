# Fu combines the logic–less portability of Mustache with the terse utility of Haml.

require "fu/version"
require "fu/error"
require "fu/parser"
require "fu/mustache"

module Fu
  def self.to_mustache(fu)
    Fu::Mustache.new(Fu::Parser.new(fu).root).mustache
  end
end
