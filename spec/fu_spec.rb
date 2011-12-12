require 'spec_helper'
describe Fu::Mustache do
  it "can build a div from a single class" do
    Fu.to_mustache(".klass").should eq '<div class="klass"></div>'
  end

  it "can add multiple classes by appending" do
    Fu.to_mustache(".klass.odd").should eq '<div class="klass odd"></div>'
  end

  it "allows tag type to be specified on the line" do
    Fu.to_mustache("%video").should eq "<video></video>"    
  end

  it "knows that some tags are self closing" do
    Fu.to_mustache("%br").should eq "<br/>"
  end

  it "can specify a tag name, classes and a dom-id just by piling on statements" do
    result = Fu.to_mustache("%tag.klass1.klass2#identifier")
    result.should =~ /^\<tag\ /
    result.should =~ /class\=\"klass1 klass2\"/
    result.should =~ /id\=\"identifier\"/
  end

  it "handles inline text children" do
    Fu.to_mustache("%h1 This is a title").should eq "<h1>This is a title</h1>"
  end

  it "allows the designer to provide arbitrary attributes" do
    result = Fu.to_mustache <<-END
      %tag (a=1, b=2, data-c  = 
        "Dette er en stor verdi")
    END
    result.should eq '<tag a="1" b="2" data-c="Dette er en stor verdi"></tag>'
  end

  it "inserts children as sub nodes and concatenates sibling nodes" do
    result = Fu.to_mustache <<-END
      %section
        %p
          This is
          some text
          for this paragraph.
            This is added too
        But this is outside        
    END
    result.should eq "<section><p>This is some text for this paragraph. This is added too</p> But this is outside</section>"
  end

  it "handles complex hierarchies with attributes and cdata and multiple siblings at the root level" do
    result = Fu.to_mustache <<-END
      %section
        %h1.header This is a header
        %p(data-bananas="healthy but radioactive")
          This is body
          %details
            %ul.big_list
              %li Item 1
              %li Item 2
              %li Item 3
          %details.secondary
            %p
              Some details
      %section.number2
        Other stuff 
    END
    result.should eq '<section><h1 class="header">This is a header</h1> <p data-bananas="healthy but radioactive">This is body <details><ul class="big_list"><li>Item 1</li> <li>Item 2</li> <li>Item 3</li></ul></details> <details class="secondary"><p>Some details</p></details></p></section> <section class="number2">Other stuff</section>'
  end

  it "handles mustache iterators" do
    result = Fu.to_mustache <<-END
      {{#children}}
        {{name}} and {{address}}
    END
    result.should eq "{{#children}}{{name}} and {{address}}{{/children}}"
  end

  it "handles mustache in attributes" do
    Fu.to_mustache('%p(data-bingo="{{bingo}}")').should eq '<p data-bingo="{{bingo}}"></p>'
  end

  it "handles escaped quote characters in attribute values" do
    Fu.to_mustache('%p(data-quoted="\\"")').should eq '<p data-quoted="\""></p>'
  end

end