# sinatra-docdsl

DocDSL is a DSL for documenting REST APIs that are implemented using Sinatra. 

Simply tell DocDSL what each endpoint does using easy to use keywords right along with your Sinatra code and it exposes the resulting documentation via /doc on the resource.

Sinatra-docdsl integrates nicely with the Sinatra framework and extends the Sinatra DSL with a few documentation specific constructs. The current version simply produces a simple html page but it should be pretty easy to modify the rendering to produce more complex output or e.g. a WADL description file.

# Why?

We needed a tool to document our Sinatra based REST API at Localstream and I decided to write my own tool. You can check out our [API Documentation](https://localstre.am/api) for an example.

# Installation

Sinatra-docdsl is available at rubygems https://rubygems.org/gems/sinatra-docdsl. So, you can simply install it like this:

    gem install sinatra-docdsl

# Usage

Here's a sample application that shows of how you use docdsl. You can find it in the example directory. 

Notice that we there is a render function (optional) in the page declaration. It simply delegates to the builtin markdown html renderer that outputs a simple documentation page (this is the default). There is also a json implementation that you may use and it is very easy to plug in your own implementation.

    > config.ru
    
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
        header "DocDSL is a tool to document REST APIs implemented using Sinatra"
        introduction "You can use the page section to write a small introduction, add a title, and headers/footers"
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

    ## code examples
    ~~~ ruby
    puts 'hello world in ruby'
    ~~~

    Sinatra-docdsl uses the jruby friendly Kramdown dialect and you can use it anywhere, provided you use the markdown renderer (default). Of course you can
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
            
          # Of course, you can easily write your own renderer. It is executed on the @page_doc object 
          # and you have full access to the attributes in there.
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
        payload "the payload and some sample json as an example (optional. The example can be any ruby object that implements to_json)", {:gimme=>"danger"}
        response "Description of the normal response and optional sample json. The example can be any ruby object that implements to_json.", {:some_field=>'sample value'}
        status 200,"and you can document status codes"
        status 400,"the official meaning of the code is displayed as well and the explanation is optional as you can see below"
        status 404
        status 409
        status 500
      end
      post "/everything/:param1" do | param1 |    
        [200,{:theThing=>param1}.to_json]
      end
    end
    
    # wire up our sample app to rack
    map '/' do
      run DocumentedApp
    end
```

# License

This code is licensed under the expat license. See the LICENSE file for details.

# Changes

- 0.7 Add markdown support (kramdown dialect) and let render methods return a sinatra response instead of just the body
- 0.6 Fix bug where documentation block was being passed to Page constructor if there is no Page object yet.
- 0.5 Add default meaning for status codes. This saves you from having to type OK or Not Modified for e.g. 200 and 304 codes over and over again.
- 0.4 refactor to enable custom rendering and add ability to document status codes and add sample requests and responses ruby objects that are pretty printed as json
- 0.1-0.3 First few releases. 

        
# Acknowledgements

Inspired by and based on https://github.com/softprops/sinatra-doc. I've pretty much rewritten a lot of the code and tests but the original idea comes from softprops.

