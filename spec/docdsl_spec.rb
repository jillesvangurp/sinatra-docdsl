require 'rack/test'
require 'sinatra'
require 'lib/docdsl'
require 'json'

describe 'docdsl' do
  describe 'documenting with defaults' do
    class AnotherDocumentedApp < Sinatra::Base
      register Sinatra::DocDsl
  
      documentation "get a list of stuff"
      get "/stuff" do
        "..."
      end
      
      get "/undocumented" do
        "..."
      end
      
      documentation "get specific stuff" do
        param :kind, "the stuff"
      end
      get "/stuff/:kind" do
        "..."
      end
    end
    
    before(:all) do
      @browser = Rack::Test::Session.new(Rack::MockSession.new(AnotherDocumentedApp))
      @browser.get '/doc'
      @browser.last_response.ok?.should be_true
    end
    
    it 'should contain things that are documented' do
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
    
    it "should document all elements" do
      [
        "DocDSL Documentation",
        "API",
        "API Documentation for this resource",
        "Sinatra DocDSL"
      ].each { |phrase|
        @browser.last_response.body.should include(phrase)
      }      
    end
  end
    
  describe "Documenting with custom title, header, intro, and footer" do
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
        payload "the payload", {:gimme=>"danger"}
        response "and of course a the response", {:some_field=>'sample value'}
        status 200,"okidokie"
        status 400,"that was bad"
      end
      post "/everything/:param1" do
        "..."
      end
    end
    
    before(:all) do
      @browser = Rack::Test::Session.new(Rack::MockSession.new(DocumentedApp))
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
        "QED",
        "okidokie",
        "200",
        "400",
        "sample value",
        "danger"
      ].each { |phrase|
        @browser.last_response.body.should include(phrase)
      }
    end
    
    it 'should contain the default title, header, and footer' do
      [
        "url parameters",
        "query string parameters",
        'Content-Type', "header",
        'Etag', "another header",
        "the payload",
        "and of course a the response",
      ].each { |phrase|
        @browser.last_response.body.should include(phrase)
      }
    end
  end
  
  describe 'json rendering' do
    class JsonDocumentedApp < Sinatra::Base
      register Sinatra::DocDsl 
      
      page do      
        title "DocDSL demo"
        header "DocDSL API"
        introduction "is awesome"
        footer "QED"
        configure_renderer do
          self.json
        end
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
    
    it 'should return json' do
      browser = Rack::Test::Session.new(Rack::MockSession.new(JsonDocumentedApp))
      browser.get '/doc'
      parsed=JSON.parse(browser.last_response.body)
      parsed['title'].should eq "DocDSL demo"      
    end
  end
end
