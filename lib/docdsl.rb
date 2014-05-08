require 'json'
require 'kramdown'

module Sinatra
  module DocDsl
    attr_accessor :page_doc
    class PageDoc
      attr_accessor :the_title,:the_header,:the_footer,:the_introduction,:entries,:the_url_prefix

      def initialize(&block)
        @the_title='DocDSL Documentation'
        @the_header="API"
        @the_url_prefix=""
        @the_introduction="API Documentation for this resource"
        @the_footer='Powered by <strong><a href="https://github.com/jillesvangurp/sinatra-docdsl">Sinatra DocDSL</a></strong>'
        configure_renderer do
          # default
          self.render_md
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

      def url_prefix(prefix)
        @the_url_prefix=prefix
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

        [200,{'content-type' => 'application/json;charset=UTF8'},object.to_json]
      end

      def definition_list(title, definitions)
        if definitions.length > 0
          definitions.inject("### #{title}\n\n") do | dl, (k,v) |
            dl << "
#{k}
:  #{v}
"
          end
        else
          ''
        end
      end

      def render_md
        begin
          html=Kramdown::Document.new(to_markdown).to_html
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
      #{html}
    </div>
  </body>
</html>
HTML
          [200,{'content-type' => 'text/html;charset=UTF8'},body]
        rescue => e
          [500,"oops, #{e.to_s}\n#{e.backtrace}"]
        end
      end

      def md
        [200,{'content-type' => 'text/plain;charset=UTF8'},to_markdown]
      end

      def to_markdown
        markdown="
#{@the_header}

# #{@the_title}

#{@the_introduction}

"
        markdown = @entries.inject(markdown) do | md, entry |
          path = entry.paths.join(', ')
          params = definition_list("Url Parameters", entry.params)
          query_params = definition_list("Query Parameters", entry.query_params)
          header_params = definition_list("Header Parameters", entry.headers)

          if entry.the_payload
            payload="
### Request body

#{entry.the_payload}

"
            if(entry.sample_request)
              payload << "
~~~ javascript
#{::JSON.pretty_generate(entry.sample_request)}
~~~

"
            end
          end
          payload ||=''


          if entry.the_response
            response="
### Response
#{entry.the_response}

"
            if(entry.sample_response)
              response << "
~~~ javascript
#{::JSON.pretty_generate(entry.sample_response)}
~~~

"
            end
          end
          response ||=''
          status_codes=definition_list("Status codes", entry.status_codes)


          md << "
## #{path}

#{entry.desc}

#{params}

#{query_params}

#{header_params}

#{payload}

#{response}

#{status_codes}
"
        end

        markdown << "
#{@the_footer}
"
        markdown
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
          [200,{'content-type' => 'text/html;charset=UTF8'},body]
        rescue => e
          [500,"oops, #{e.to_s}\n#{e.backtrace}"]
        end
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
              payload << "<pre>#{::JSON.pretty_generate(entry.sample_request)}</pre>"
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
              response << "<pre>#{::JSON.pretty_generate(entry.sample_response)}</pre>"
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

    def doc_endpoint(path)
      @page_doc ||= PageDoc.new(&block)
      page_doc=@page_doc
      get path do
        begin
          page_doc.render
        rescue Exception=>e
          [500,"#{e.message} #{e.backtrace.inspect}"]
        end
      end
    end

    def page(&block)
      @page_doc ||= PageDoc.new(&block)
    end

    def documentation(description,&block)
      @page_doc ||= PageDoc.new
      @last_doc=DocEntry.new(description,&block)
      (@page_doc.entries ||= []) << @last_doc
    end

    def method_added(method)
      # gets called everytime a method is added to the app.
      # only triggers if the previous method was a documentation ... call
      if @last_doc
        @last_doc << method.to_s.sub(' ', " #{@page_doc.the_url_prefix}")
        @last_doc = nil
      end
      super
    end
  end
end
