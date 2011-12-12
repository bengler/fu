Fu
==

Fu combines the logic–less portability of Mustache with the terse utility of Haml. This is what it looks like:

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
