require 'cgi'

module Fu
  class Mustache
    attr_reader :mustache
    SELF_CLOSING = %w(meta img link br hr input area param col base)

    def initialize(root)
      @mustache = render_children(root)
    end

    private

    def render_children(node)
      node.children.map { |child| self.send("render_#{child.type}", child).strip }.join(' ')
    end

    def render_text(node)
      [CGI.escapeHTML(node.text), render_children(node)].compact.join(' ')
    end

    def render_mustache(node)
      if node.statement[0] == '#'
        identifier = node.statement[1..-1]
        "{{##{identifier}}}#{render_children(node)}{{/#{identifier}}}"
      else
        "{{#{node.statement}}}#{render_children(node)}"
      end
    end

    def render_element(node)
      tag = (node.tag || 'div').downcase
      attributes = (node.attributes||{}).dup
      attributes[:class] = [attributes[:class], node.css_classes].flatten.compact.join(' ')
      attributes[:id] = node.dom_id
      attribute_string = attributes.select{|k,v| v && !v.empty?}.map{|k,v| "#{k}=\"#{v}\""}.map{|s| " #{s}"}.join
      if SELF_CLOSING.include?(tag) && node.children.empty?
        "<#{tag}#{attribute_string}/>"
      else
        "<#{tag}#{attribute_string}>#{render_children(node)}</#{tag}>"
      end
    end
  end
end