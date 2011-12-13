![Puts the Fu in Mustache](http://2.bp.blogspot.com/-_i2s2gzRwgw/TZCLNfnXg4I/AAAAAAAAAEg/_fIOfF6cUxw/s1600/the-face-of-fu-manchu-original.jpg)

Fu
==

Fu combines the logic–less portability of Mustache with the terse utility of Haml. This is what it looks like:

    %ul
      {{#children}}
        %li {{name}}

Then in the (Sinatra) app:

    get "/list" do
      fu :list, :locals => {:children => [{:name => "Arne"}, {:name => "Bjarne"}]}
    end

And you get:

    <ul><li>Arne</li><li>Bjarne</li></ul>
    
A contrived example using all aspects of the syntax:

    %h1 Hello, {{user_name}}
    %p.text
      This is a paragraph of 
      text.    
    %ul.friend_list(data-attribute1="some data", data-attribute2="{{some_mustache_data}}")
      {{#friends}}
        %li
          {{>friend_partial}}
      {{^friends}}
        %p.error
          You, unfortunately, have no friends.
    
Usage
=====

Direct:

    Fu.to_mustache("%p Hello {{mustache}}")

With Sinatra and Tilt:

    require 'fu/tilt'

Stick your fu-templates in your views-folder with the extension `.fu`.    

Then, in your app:

    get "/some_action" do
      fu :some_template, :locals => {...}
    end

Todo
====

* Support `/`-comments
 