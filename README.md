# sinatra-docdsl

Simple DSL for documenting sinatra resources and exposing the resulting documentation via /doc on the resource.

# install

    > gem install sinatra-docdsl 

# usage

    > your app.rb
    
    class App < Sinatra::Base
      register Sinatra::Doc
      
      doc "gets a list of"
      get "something" { ... }
    
      doc "you get", { 
        :id => "the id"
      }
      get "whatever/:id" { ... }
    end
        
# Props

Inspired by and based on https://github.com/softprops/sinatra-doc.