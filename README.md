# sinatra-docdsl

Simple DSL for documenting sinatra resources and exposing the resulting documentation via /doc on the resource.

Note: this is a work in progress.

# install
	TODO actually deploy the gem, for now build it yourself
    
    > gem install sinatra-docdsl

# Usage

    > your app.rb
class AnotherDocumentedApp < Sinatra::Base
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
end

# License

This code is licensed under the expat license. See the LICENSE file for details.
        
# Acknowledgements

Inspired by and based on https://github.com/softprops/sinatra-doc. I've pretty much rewritten a lot of the code and tests but the original idea comes from softprops.

