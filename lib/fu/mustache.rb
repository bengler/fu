# Renders Mustache templates from a Fu parse-tree

require 'cgi'

module Fu
  class Mustache    
    attr_reader :mustache
    SELF_CLOSING_TAGS = %w(meta img link br hr input area param col base)
    BLOCK_ACTIONS = %w(# ^)   # <- Mustache actions that take a block
    NO_SPACE_CHARS = /[{}<>]/ # <- Characters that do not need to be separated by a space
                              #    when joining elements (e.g. "<p>!</p>", not "<p> ! </p>")

    def initialize(root)
      @mustache = flatten(render_children(root))
    end

    private

    # Flatten the tag_tree inserting spaces only where they have to be.
    def flatten(tag_tree)
      tag_tree.flatten.inject("") do |result, element| 
        if result[-1] =~ NO_SPACE_CHARS || element[0] =~ NO_SPACE_CHARS
          "#{result}#{element}"
        else
          "#{result} #{element}"
        end
      end
    end

    # Returns a tag-tree of nested arrays reflecting the structure of the
    # document. E.g. ["<p>",["<em>", "Italicized text", "</em>"],"</p>"]
    def render_children(node)
      node.children.map { |child| self.send("render_#{child.type}", child) }
    end

    def render_text(node)
      [CGI.escapeHTML(node.text), render_children(node)].compact
    end

    def render_mustache(node)
      /^\s*(?<action>[#>^]?)\s*(?<identifier>.*)\s*$/ =~ node.statement
      if BLOCK_ACTIONS.include?(action)
        ["{{#{action}#{identifier}}}", render_children(node), "{{/#{identifier}}}"]
      else
        ["{{#{node.statement}}}", render_children(node)]
      end
    end

    def render_element(node)
      tag = (node.tag || 'div').downcase
      attributes = (node.attributes||{}).dup
      attributes[:class] = [attributes[:class], node.css_classes].flatten.compact.join(' ')
      attributes[:id] = node.dom_id
      attribute_string = attributes.select{|k,v| v && !v.empty?}.map{|k,v| "#{k}=\"#{v}\""}.map{|s| " #{s}"}.join
      if SELF_CLOSING_TAGS.include?(tag) && node.children.empty?
        ["<#{tag}#{attribute_string}/>"]
      else
        ["<#{tag}#{attribute_string}>", render_children(node), "</#{tag}>"]
      end
    end
  end
end