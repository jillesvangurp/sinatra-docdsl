module Sinatra
  module DocDsl
    class PageDoc
      attr_accessor :title,:header,:footer,:introduction
      
      def initialize()
        @title='DocDSL Documentation'
        @header="API"
        @introduction="API Documentation for this resource"
        @footer="Powered by <strong>Sinatra DocDSL</strong>"
      end
    end
    
    class DocEntry
      attr_accessor :desc,:params,:paths,:query_params,:headers,:payload,:response
      
      def initialize()
        @paths=[]
        @desc='...'
        @params={}
        @query_params={}
        @headers={} 
        @payload=nil
        @response=nil     
      end
            
      def <<(path)
        self.paths << path
      end
      
      def to_s
        self.inspect
      end
      
      def inspect
        "#{@paths.join(', ')} # #{@desc}"
      end
    end
    
    def self.registered(app)
      app.get '/doc' do
        app.instance_eval { render_docs_page(@docs) }
      end      
    end
    
    def ensure_doc_exists
      if !@last_doc
        @last_doc = DocEntry.new()
        (@docs ||= []) << @last_doc
      end      
    end
    
    def doc(desc, params = {})
      ensure_doc_exists
      @last_doc.desc=desc
      @last_doc.params=params
    end
    
    def payload(desc)
      ensure_doc_exists
      @last_doc.payload=desc
    end
    
    def response(desc)
      ensure_doc_exists
      @last_doc.response=desc      
    end
    
    def param(name,desc)
      ensure_doc_exists
      @last_doc.params[name]=desc      
    end
    
    def header(name,desc)
      ensure_doc_exists
      @last_doc.headers[name]=desc      
    end
    
    def query_param(name,desc)
      ensure_doc_exists
      @last_doc.query_params[name]=desc      
    end
    
    def title(t)
      @page_doc ||= PageDoc.new
      @page_doc.title=t
    end
    
    def header(h)
      @page_doc ||= PageDoc.new
      @page_doc.header=h
    end
    
    def footer(f)
      @page_doc ||= PageDoc.new
      @page_doc.footer=f
    end
    
    def introduction(i)
      @page_doc ||= PageDoc.new
      @page_doc.introduction=i
    end
    
    def method_added(method)
      # don't document /doc
      return if method.to_s =~ /(^(GET|HEAD) \/doc\z)/
      # document the method and nullify last_doc so that a new one gets created for the next method
      if method.to_s =~ /(GET|POST|PUT|DELETE|UPDATE|HEAD)/ && @last_doc
        @last_doc << method
        @last_doc = nil
      end
      super
    end
    
    def render_docs_list(entries) 
      entries.inject('') { | markup, entry|
        path = entry.paths.join(', ')
        if entry.params.length >0
          params = entry.params.inject("<h3>Url Parameters</h3>\n<dl>") { |li,(k,v)|
            li << "<dt>:%s</dt><dd>%s</dd>" % [k,v]
          }
          params << "</dl>\n"
        end
        params ||= ''
        
        if entry.query_params.length >0
          query_params = entry.query_params.inject("<h3>Query Parameters</h3>\n<dl>") { |li,(k,v)|
            li << "<dt>:%s</dt><dd>%s</dd>" % [k,v]
          }
          query_params << "</dl>\n"
        end 
        query_params ||=''
        
        
        if entry.query_params.length >0
          headers = entry.headers.inject("<h3>Header Parameters</h3>\n<dl>") { |li,(k,v)|
            li << "<dt>:%s</dt><dd>%s</dd>" % [k,v]
          }
          headers << "</dl>\n"
        end
        headers ||= ''

        markup << "<h2>%s</h2>\n<p>%s</p>\n%s%s%s" % [path, entry.desc, params, query_params, headers]
      } << ""
    end
    
    def render_docs_page(entries)
      begin
        @page_doc ||= PageDoc.new
        body= <<-HTML
          <html>
            <head>
              <title>#{@page_doc.title}</title>
              <style type="text/css">
                #container{width:960px; margin:1em auto; font-family:monaco, monospace;}
                dt{ background:#f5f5f5; font-weight:bold; float:left; margin-right:1em; }
                dd{ margin-left:1em; }
              </style>
            </head>
            <body>
              <div id="container">
                <h1 id="title">#{@page_doc.header}</h1>
                <p>#{@page_doc.introduction}</p>
              
                #{render_docs_list(entries)}
                <p>#{@page_doc.footer}</p>
              </div>
            </body>
          </html>
        HTML
      rescue => e
        puts e.to_s
      end
      [200,body]
    end 
  end
end
