module OmnitureClient
  module Printer

    def url(ssl = false)
      suite = OmnitureClient::suite.is_a?(Array) ? OmnitureClient::suite.join(',') : OmnitureClient::suite
      base_url =  ssl == :ssl ? OmnitureClient::ssl_url : OmnitureClient::base_url
      "#{base_url}/b/ss/#{suite}/#{OmnitureClient::version}/#{rand(9999999)}?#{query}"
    end
    
    def js(ssl = false)
      #suite = OmnitureClient::suite.is_a?(Array) ? OmnitureClient::suite.join(',') : OmnitureClient::suite
      #base_url = ssl == :ssl ? OmnitureClient::ssl_url : OmnitureClient::base_url
      output = <<-JS
        <script type="text/javascript">
          var s_account = "#{OmnitureClient::account}";
        </script>
        <script type="text/javascript" src="#{ActionController::Base.relative_url_root}/javascripts/#{OmnitureClient::js_include}"></script>
        <script type="text/javascript">
          #{js_vars}
          var s_code=s_tan.t(); if(s_code)document.write(s_code);
        </script>
      JS
    end
    
    def raw
      raw_vars
    end

    def query
      vars.inject([]) do |query, var|
        query << var_to_query(var) if var.value && var.value != ""
        query
      end.join('&')
    end
    
    def js_vars
      vars.inject([]) do |query, var|
        query << var_to_js(var) if var.value && var.value != ""
        query
      end.join(";\n") + ';'
    end
    
    def raw_vars
      vars.inject([]) do |query, var|
        query << { var.name.to_sym => var.value } if var.value && var.value != ""
        query
      end
    end

    private

    def var_to_query(var)
      "#{ CGI::escape(var.name) }=#{ CGI::escape(var.value) }" if var
    end
    
    def var_to_js(var)
      %Q{\t#{OmnitureClient::var_prefix + '.' if OmnitureClient::var_prefix}#{var.name}="#{var.value}"} if var
    end
  end
end
