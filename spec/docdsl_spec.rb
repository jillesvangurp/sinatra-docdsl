require 'rack/test'
require 'sinatra'
require 'lib/docdsl'

describe 'docdsl' do
  describe 'documenting with defaults' do
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
    
    before(:all) do
      @browser = Rack::Test::Session.new(Rack::MockSession.new(SomeDocumentedApp))
      @browser.get '/doc'
      @browser.last_response.ok?.should be_true
    end
    
    it 'should contain things that was documented' do
      [
        "GET /stuff",
        "get a list of stuff",
        "/stuff/:kind",
        "get specific stuff",
        "the stuff"
      ].each { |phrase|
        @browser.last_response.body.should include(phrase)
      }
    end
  
    it 'should not contain things that were not documented' do
      @browser.last_response.body.should_not include("/undocumented")
    end 
    
    it 'should contain the default title, header, and footer' do
      [
        "DocDSL Documentation",
        "API",
        "API Documentation for this resource",
        "Powered by <strong>Sinatra DocDSL</strong>"
      ].each { |phrase|
        @browser.last_response.body.should include(phrase)
      }
      
    end
  end
    
  describe "Documenting with custom title, header, intro, and footer" do
    class AnotherDocumentedApp < Sinatra::Base
      register Sinatra::DocDsl
      
      title "DocDSL demo"
      header "DocDSL API"
      introduction "is awesome"
      footer "QED"
  
      doc "get a list of things"
      get "/things" do
        "..."
      end
    end
    
    before(:all) do
      @browser = Rack::Test::Session.new(Rack::MockSession.new(AnotherDocumentedApp))
      @browser.get '/doc'
      @browser.last_response.ok?.should be_true
    end
    
    it 'should include strings' do
      [
        "DocDSL demo",
        "DocDSL API",
        "is awesome",
        "GET /things",
        "get a list of things",
        "QED"
      ].each { |phrase|
        @browser.last_response.body.should include(phrase)
      }
    end
  end
end
