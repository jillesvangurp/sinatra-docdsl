module Sinatra
  module DocDsl
    
    class PageDoc
      attr_accessor :the_title,:the_header,:the_footer,:the_introduction
      
      def initialize(&block)
        @the_title='DocDSL Documentation'
        @the_header="API"
        @the_introduction="API Documentation for this resource"
        @the_footer='Powered by <strong><a href="https://github.com/jillesvangurp/sinatra-docdsl">Sinatra DocDSL</a></strong>'
        
        if(block)
          if block.arity == 1
            block(self)
          else
            instance_eval(&block)
          end
        end
      end
      
      def title(t)
        @the_title=t
      end
      
      def header(h)
        @the_header=h
      end
      
      def footer(f)
        @the_footer=f
      end
      
      def introduction(i)
        @the_introduction=i
      end
    end
    
    class DocEntry
      attr_accessor :desc,:params,:paths,:query_params,:headers,:the_payload,:the_response
      
      def initialize(description, &block)
        @paths=[]
        @desc=description
        @params={}
        @query_params={}
        @headers={} 
        @the_payload=nil
        @the_response=nil 
        if(block)
          if block.arity == 1
            block(self)
          else
            instance_eval(&block)
          end
        end
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
      
      def describe(desc)
        @desc=desc
      end
      
      def payload(desc)
        @the_payload=desc
      end
      
      def response(desc)
        @the_response=desc      
      end
      
      def param(name,desc)
        @params[name]=desc      
      end
      
      def header(name,desc)
        @headers[name]=desc      
      end
      
      def query_param(name,desc)
        @query_params[name]=desc      
      end
      
    end
    
    def self.registered(app)
      app.get '/doc' do
        app.instance_eval { render_docs_page(@docs) }
      end      
    end
    
    def page(&block)
      @page_doc = PageDoc.new(&block)
    end
    
    def documentation(description,&block)
      @last_doc=DocEntry.new(description,&block)
      (@docs ||= []) << @last_doc
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
        
        
        if entry.headers.length >0
          headers = entry.headers.inject("<h3>Header Parameters</h3>\n<dl>") { |li,(k,v)|
            li << "<dt>%s</dt><dd>%s</dd>" % [k,v]
          }
          headers << "</dl>\n"
        end
        headers ||= ''
        
        if entry.the_payload
          payload="<dt>Payload</dt><dd>#{entry.the_payload}</dd>"
        end
        payload ||=''
        if entry.the_response
          response="<dt>Response</dt><dd>#{entry.the_response}</dd>"          
        end
        response ||=''

        markup << "<h2>%s</h2>\n<p>%s</p>\n%s%s%s%s%s" % [path, entry.desc, params, query_params, headers,payload,response]
      } << ""
    end
    
    def render_docs_page(entries)
      begin
        @page_doc ||= PageDoc.new
        body= <<-HTML
          <html>
            <head>
              <title>#{@page_doc.the_title}</title>
              <style type="text/css">
                #container{width:960px; margin:1em auto; font-family:monaco, monospace;}
                dt{ background:#f5f5f5; font-weight:bold; float:left; margin-right:1em; }
                dd{ margin-left:1em; }
              </style>
            </head>
            <body>
              <div id="container">
                <h1 id="title">#{@page_doc.the_header}</h1>
                <p>#{@page_doc.the_introduction}</p>
              
                #{render_docs_list(entries)}
                <br/>
                <hr>
                <p>#{@page_doc.the_footer}</p>
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
