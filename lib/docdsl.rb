require 'json'

module Sinatra
  module DocDsl
    class PageDoc
      attr_accessor :the_title,:the_header,:the_footer,:the_introduction,:entries
      
      def initialize(&block)
        @the_title='DocDSL Documentation'
        @the_header="API"
        @the_introduction="API Documentation for this resource"
        @the_footer='Powered by <strong><a href="https://github.com/jillesvangurp/sinatra-docdsl">Sinatra DocDSL</a></strong>'
        configure_renderer do
          self.html
        end
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
      
      def configure_renderer(&block)
        @render_function=block
      end      
      
      def render
        @render_function.call
      end
      
      def json
        entries=[]
        @entries.each do |entry|
          entries << entry.json
        end
        object={
          :title=> @the_title,:header=>@the_header,:footer=>@the_footer,:introduction=>@the_introduction,
          :endPoints=>entries
        }
      
        object.to_json
      end
      
      def html
        begin
          body= <<-HTML
            <html>
              <head>
                <title>#{@the_title}</title>
                <style type="text/css">
                  #container{width:960px; margin:1em auto; font-family:monaco, monospace;font-size:11px;}
                  dt{ background:#f5f5f5; font-weight:bold; float:left; margin-right:1em; }
                  dd{ margin-left:1em; }
                </style>
              </head>
              <body>
                <div id="container">
                  <h1 id="title">#{@the_header}</h1>
                  <p>#{@the_introduction}</p>
              
                  #{render_html_entries}
                  <br/>
                  <hr>
                  <p>#{@the_footer}</p>
                </div>
              </body>
            </html>
          HTML
        rescue => e
          puts e.to_s
        end
        body
      end 
    
      def render_html_entries 
        @entries.inject('') { | markup, entry|
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
            payload="<dt>Payload</dt><dd>#{entry.the_payload}\n"
            if(entry.sample_request)
              payload << "<pre>#{JSON.pretty_generate(entry.sample_request)}</pre>"
            end
            payload << "</dd>"
          end
          payload ||=''
          if entry.the_response
            statuscodes=''
            if entry.status_codes.length >0
              status_codes="<dl>\n"
              entry.status_codes.each do |status,meaning|
                statuscodes << "<dt>#{status}</dt><dd>#{meaning}</dd>\n"
              end
              status_codes << "</dl>\n"
            end
            
            response="<dt>Response</dt><dd>#{entry.the_response}\n#{statuscodes}\n"          
            if(entry.sample_response)
              response << "<pre>#{JSON.pretty_generate(entry.sample_response)}</pre>"
            end
            response << "</dd>"
          end
          response ||=''

          markup << "<h2>%s</h2>\n<p>%s</p>\n%s%s%s%s%s" % [path, entry.desc, params, query_params, headers,payload,response]
        } << ""
      end
    end
    
    class DocEntry
      attr_accessor :desc,:params,:paths,:query_params,:headers,:the_payload,:the_response,:sample_request,:sample_response,:status_codes
      
      def initialize(description, &block)
        @paths=[]
        @desc=description
        @params={}
        @query_params={}
        @headers={} 
        @the_payload=nil
        @sample_request=nil
        @the_response=nil 
        @sample_response=nil
        @status_codes={}
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
      
      def payload(desc, example=nil)
        @the_payload=desc
        @sample_request=example
      end
      
      def response(desc,example=nil)
        @the_response=desc 
        @sample_response=example     
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
      
      def status(code,meaning=nil)
        official_meaning=status_codes_map[code]
        if meaning
          @status_codes[code]="#{official_meaning} - #{meaning}"
        else
          @status_codes[code]=official_meaning
        end
      end
      
      def status_codes_map
        {
          100=> 'Continue',
          101=> 'Switching Protocols',
          102=> 'Processing',
          200=> 'OK',
          201=> 'Created',
          202=> 'Accepted',
          203=> 'Non Authoritative Information',
          204=> 'No Content',
          205=> 'Reset Content',
          206=> 'Partial Content',
          207=> 'Multi-Status',
          300=> 'Mutliple Choices',
          301=> 'Moved Permanently',
          302=> 'Moved Temporarily',
          303=> 'See Other',
          304=> 'Not Modified',
          305=> 'Use Proxy',
          307=> 'Temporary Redirect',
          400=> 'Bad Request',
          401=> 'Unauthorized',
          402=> 'Payment Required',
          403=> 'Forbidden',
          404=> 'Not Found',
          405=> 'Method Not Allowed',
          406=> 'Not Acceptable',
          407=> 'Proxy Authentication Required',
          408=> 'Request Timeout',
          409=> 'Conflict',
          410=> 'Gone',
          411=> 'Length Required',
          412=> 'Precondition Failed',
          413=> 'Request Entity Too Large',
          414=> 'Request-URI Too Long',
          415=> 'Unsupported Media Type',
          416=> 'Requested Range Not Satisfiable',
          417=> 'Expectation Failed',
          500=> 'Internal Server Error',
          503=> 'Temporarily Unavailable'
        }
      end
      
      def json
        {
            :description=>@desc, 
            :url_parameters=>@params, 
            :paths=>@paths, 
            :query_parameters=>@query_params, 
            :headers=>@headers, 
            :payload=>@the_payload, 
            :sample_request=>@sample_request,
            :response=>@the_response,
            :status_codes=>@status_codes,
            :sample_response=>@sample_response
        }
      end
    end  
    
    def self.registered(app)
      app.get '/doc' do
        begin
          app.instance_eval { 
            @page_doc ||= PageDoc.new             
            [200,@page_doc.render]
          }
        rescue Exception=>e
          puts e.message, e.backtrace.inspect
          [500,@page_doc.render]
        end
      end      
    end
        
    def page(&block)
      @page_doc ||= PageDoc.new(&block)
    end
    
    def documentation(description,&block)
      @page_doc ||= PageDoc.new(&block)
      @last_doc=DocEntry.new(description,&block)
      (@page_doc.entries ||= []) << @last_doc
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
  end
end
