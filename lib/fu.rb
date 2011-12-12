require "fu/version"
require "fu/error"
require "fu/parser"
require "fu/mustache"

module Fu
  def self.parse(text)
    Fu::Parser.new(text).root
  end

  def self.to_mustache(fu)
    Fu::Mustache.new(parse(fu)).mustache
  end
end
