require 'strscan'
require 'ostruct'

module Fu
  class Parser
    attr_reader :root

    def initialize(text)
      @root = OpenStruct.new(:type => :root, :children => [])
      scanner = StringScanner.new(text.gsub(/\t/, '  '))
      parse_children(@root, scanner)
    end

    private

    def parse_children(parent, scanner, parent_indent = -1)
      indent = (scanner.check(/\ +/) || '').size
      while indent > parent_indent && !scanner.eos? do
        node = parse_line(parent, scanner)
        parse_children(node, scanner, indent)
        indent = (scanner.check(/\ +/) || '').size 
      end
    end

    def parse_line(parent, scanner)
      scanner.scan(/[^\S\n]*/) # Consume any leading spaces
      node = OpenStruct.new(:parent => parent, :children => [])
      parent.children << node
      # If present, the line must open with tag or script
      if element_statement = scanner.scan(/\%[a-zA-Z0-9\-_]+/) # e.g. '%video'
        node.type = :element
        node.tag = element_statement[1..-1]
      elsif mustache_statement = scanner.scan(/\{\{[^\S\n]*[#\^][^\S\n]*[a-zA-Z0-9_]+[^\S\n]*\}\}/) # e.g. = - #comments 
        node.type = :mustache
        node.statement = mustache_statement.scan(/[#\^]\s*[a-zA-Z0-9_]+/).flatten.first
      end

      # Classes and id's may be added, e.g. #my_special_header_id.alert.featured
      while scan = scanner.scan(/[\.\#][a-zA-Z0-9\-_]+/) do 
        unless node.type.nil? || node.type == :element
          raise SyntaxError.new("Can only attach id's or classes to elements", scanner.pos) 
        end
        node.type = :element
        node.tag ||= 'div'
        node.attributes ||= {}
        case scan[0]
        when '.' then (node.css_classes ||= []) << scan[1..-1]
        when '#' then node.dom_id = scan[1..-1]    
        end      
      end

      # Attributes-section, e.g. (hidden=true, data-bananas="one, two, five")
      if node.type == :element && scan = scanner.scan(/[^\S\n]*\(/)
        node.attributes ||= {}
        begin
          scanner.scan(/\s*/) # whitespace and commas
          key = scanner.scan(/[a-zA-Z0-9\-_]+/)
          value = nil
          raise SyntaxError.new("Expected '='", scanner.pos) unless scanner.scan(/\s*\=\s*/)
          quote = scanner.scan(/['"]/)
          if quote
            scan = scanner.scan(/[^\n]*?(?<!\\)#{'\\'+quote}/) # Consume anything until a matching, unescaped quote
            value = scan.chomp(quote)
          else
            value = scanner.scan(/[a-zA-Z0-9\-_]+/) # Simple values need not be quoted
          end
          node.attributes[key] = value
          raise SyntaxError.new("Expected attribute value", scanner.pos) unless value
          scanner.scan(/\s*,/) # discard any comma
        end until scanner.scan(/\s*\)/)
      end

      # Any text?
      scan = scanner.scan(/[^\n]+/)
      unless scan.nil? || scan.strip.empty?
        if node.type # Is this a trailing child like e.g.: %h1.title This is a trailing child
          node.children << OpenStruct.new(
            :parent => node, :children => [], 
            :type => :text, :text => scan.strip
          )  
        else # This very node is teh text!
          node.type = :text
          node.text = scan.strip
        end
      end
      scanner.scan(/\n/) # Consume end of line
      node
    end
  end
end