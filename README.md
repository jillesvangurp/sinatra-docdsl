# sinatra-docdsl

A simple DSL for generating documentation for Sinatra REST applications. 

- document REST end points, url & query parameters, headers, request & response bodies.
- use **markdown** in your documentation (uses kramdown, which supports the Github flavor of markdown)
- customize documentation rendering
- render documentation via a Sinatra end point on the resource, e.g. "/doc"

# Why?

We needed a tool to document our Sinatra based REST API at Localstream and I decided to write my own tool. You can check out our [API Documentation](https://localstre.am/api) for an example.

Writing documentation is a bit of a chore. Over the years, I've learned that the best documentation is written in line with the source code. Doing it after the fact means that quite often it doesn't get done, it gets done poorly, or it is neglected once it is written. Docdsl tries to make the writing and maintenance of API documentation as straightforward as possible. 

# Installation

Sinatra-docdsl is available at rubygems https://rubygems.org/gems/sinatra-docdsl. So, you can simply install it like this:

    gem install sinatra-docdsl

# Usage

Here's a sample application that shows of how you use docdsl. You can find it in the example directory. Most of what you see is optional: you can add as much or as little documentation as you need. 

config.ru:

``` ruby
require 'sinatra'
require 'json'
require 'docdsl'

# simple sinatra app to demo how you use DocDSL
class DocumentedApp < Sinatra::Base
  
  # register to enable docdsl
  register Sinatra::DocDsl 
  
  # specify some meta data for your documentation page (optional)
  page do      
    title "DocDSL demo"
    header "Displayed before the title."
    introduction "A short introduction to your API."
    footer "
# Footer section
As of 0.7.0, Sinatra docdsl supports markdown. For example, this entire footer section is written using markdown.

# heading 1

## bullets
- bullets
- bullets

## numbered list

1. numbered list
1. numbered list

etc.

Sinatra-docdsl uses the jruby friendly Kramdown dialect and you can use it anywhere, 
provided you use the markdown renderer (default). Of course you can
configure other renderers.
"
    # configuring the renderer is optional, and in this case just uses the default
    configure_renderer do
      # if you use the provided render_md, you can use markdown in your documentation. 
      #This uses a simple markdown template to render an html page using kramdown
      self.render_md
      
      # if you want to get at the raw markdown
      # self.md
      
      # we have a json renderer as well, uncomment to enable
      # self.json   
      
      # finally, we have a simple html template that does not rely on markdown
      # self.html
            
      # Of course, you can easily write your own renderer. It is executed on 
      # the @page_doc object and you have full access to the attributes in there.
      # be sure to return a valid sinatra response, e.g. [200,'hello wrld']
    end
  end
  
  # add documentation for your end points with a documentation section
  documentation "Nothing under /. Go look at /docs" do
    response "redirects to the documentation page"
    status 303
  end
  get "/" do
    redirect "/doc"
  end


  documentation "This is a simple example. The do bit is optional."
  get "/things" do
    [200,"[1,2,3]"]
  end
  
  documentation "post a blob" do
    payload "some json content"
    response "some other json content"
  end
  post "/things" do
    [200,"[42]"]
  end

  documentation "you can document all aspects of your REST endpoint, if you want." do
    param :param1, "url parameters"
    query_param :queryParam1, "query string parameters"
    header 'Content-Type', "header"
    header 'Etag', "another header"
    payload "description of the request body", 
      {:rubyfragment=>"will be rendered as json", :optional=>true}
    response "Description of the response", {:some_field=>'sample value', :optional=>true}
    status 200,"and you can document status codes"
    status 400,"the official meaning of the code is displayed by default"
    status 404,"so you can leave out the optional description"
    status 409
    status 500
  end
  post "/everything/:param1" do | param1 |    
    [200,{:theThing=>param1}.to_json]
  end
  
  # this tells docdsl to render the documentation when you do a GET on /doc
  doc_endpoint "/doc"  
end

# wire up our sample app to rack
map '/' do
  run DocumentedApp
end

```

# License

This code is licensed under the expat license. See the LICENSE file for details.

# Changes

- 0.8 Make the documentation end point explicitly configurable via doc_endpoint
- 0.7 Add markdown support (kramdown dialect) and let render methods return a sinatra response instead of just the body
- 0.6 Fix bug where documentation block was being passed to Page constructor if there is no Page object yet.
- 0.5 Add default meaning for status codes. This saves you from having to type OK or Not Modified for e.g. 200 and 304 codes over and over again.
- 0.4 refactor to enable custom rendering and add ability to document status codes and add sample requests and responses ruby objects that are pretty printed as json
- 0.1-0.3 First few releases. 

        
# Acknowledgements

Inspired by and based on https://github.com/softprops/sinatra-doc. I've pretty much rewritten a lot of the code and tests but the original idea comes from softprops.

