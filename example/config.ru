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
