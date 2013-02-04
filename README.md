# sinatra-docdsl

DSL for documenting Sinatra applications and exposing the resulting documentation via /doc on the resource.

Sinatra-docdsl integrates nicely with the Sinatra framework and extends the Sinatra DSL with a 
few documentation specific constructs. The current version simply produces a 
simple html page but it should be pretty easy to modify the rendering to produce more complex output
or e.g. a WADL description file.

# install

Sinatra-docdsl is available at rubygems https://rubygems.org/gems/sinatra-docdsl. So, you can simply install it like this:

    gem install sinatra-docdsl

# Usage

    > your app.rb
    class DocumentedApp < Sinatra::Base
      register Sinatra::DocDsl 
      
      page do      
        title "DocDSL demo"
        header "DocDSL API"
        introduction "is awesome"
        footer "QED"
      end
  
      documentation "get a list of things"
      get "/things" do
        "{}"
      end
      
      documentation "post a blob" do
        payload "some json content"
        response "some other json content"
      end

      post "/things" do
        "{}"
      end

      documentation "you can document" do
        param :param1, "url parameters"
        query_param :queryParam1, "query string parameters"
        header 'Content-Type', "header"
        header 'Etag', "another header"
        payload "the payload"
        response "and of course a the response"
      end
      post "/everything/:param1" do
        "..."
      end
    end

# License

This code is licensed under the expat license. See the LICENSE file for details.
        
# Acknowledgements

Inspired by and based on https://github.com/softprops/sinatra-doc. I've pretty much rewritten a lot of the code and tests but the original idea comes from softprops.

