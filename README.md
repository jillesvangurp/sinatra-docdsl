# sinatra-docdsl

Simple DSL for documenting sinatra resources and exposing the resulting documentation via /doc on the resource.

Note: this is a work in progress.

# install
	TODO actually deploy the gem, for now build it yourself
    > gem install sinatra-docdsl

# Usage

    > your app.rb
    
    TODO update documentation; for now you are better off looking at the tests
    
    class App < Sinatra::Base
      register Sinatra::Doc
      
      doc "gets a list of"
      get "something" { ... }
    
      doc "you get", { 
        :id => "the id"
      }
      get "whatever/:id" { ... }
    end

# License

This code is licensed under the expat license. See the LICENSE file for details.
        
# Acknowledgements

Inspired by and based on https://github.com/softprops/sinatra-doc. I've pretty much rewritten a lot of the code and tests but the original idea comes from softprops.

