require 'rack/test'
require 'sinatra'
require 'lib/docdsl'

describe 'docdsl' do
  it 'should document the API with defaults' do
    class SomeDocumentedApp < Sinatra::Base
      register Sinatra::DocDsl
  
      doc "get a list of stuff"
      get "/stuff" do
        "..."
      end
      
      get "/undocumented" do
        "..."
      end
      
      doc "get specific stuff", { 
        :kind => "the stuff"
      }
      get "/stuff/:kind" do
        "..."
      end
    end
    browser = Rack::Test::Session.new(Rack::MockSession.new(SomeDocumentedApp))
    browser.get '/doc'
    browser.last_response.ok?.should be_true
    [
      "GET /stuff",
      "get a list of stuff",
      "/stuff/:kind",
      "get specific stuff",
      "the stuff"
    ].each { |phrase|
      browser.last_response.body.should include(phrase)
    }

    browser.last_response.body.should_not include("/undocumented")
  end
    
  it "should render the title, header, and footer" do
    class AnotherDocumentedApp < Sinatra::Base
      register Sinatra::DocDsl
      
      title "DocDSL demo"
      header "DocDSL API"
      introduction "is awesome"
  
      doc "get a list of things"
      get "/things" do
        "..."
      end
    end
    browser = Rack::Test::Session.new(Rack::MockSession.new(AnotherDocumentedApp))
    browser.get '/doc'
    browser.last_response.ok?.should be_true
    [
      "DocDSL demo",
      "DocDSL API",
      "GET /things",
      "get a list of things"
    ].each { |phrase|
      browser.last_response.body.should include(phrase)
    }
  end
end
