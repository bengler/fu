![Puts the Fu in Mustache](http://2.bp.blogspot.com/-_i2s2gzRwgw/TZCLNfnXg4I/AAAAAAAAAEg/_fIOfF6cUxw/s1600/the-face-of-fu-manchu-original.jpg)

Fu
==

Fu combines the logic–less portability of Mustache with the terse utility of Haml. This is what it looks like:

    %ul
      {{#children}}
        %li {{name}}
    
...

    %h1(id="{{special_id}}") Hello, {{user_name}}
    .text
      %p
        This is a paragraph of 
        text.
    .friend_list
      {{#friends}}
        {{>friend_partial}}        
    
Usage
=====

    Fu.to_mustache("%p Hello {{mustache}}")

With sinatra:

    require 'fu/tilt'

Stick your fu-templates in your views-folder with the extension `.fu`.    

Meanwhile, in your app:

    get "/some_action" do
      fu :some_template, :locals => {...}
    end

