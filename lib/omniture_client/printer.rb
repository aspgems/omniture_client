module OmnitureClient
  module Printer

    def url(ssl = false)
      "#{base_url(ssl)}/b/ss/#{suite}/#{OmnitureClient::version}/#{rand(9999999)}?#{query}"
    end

    def js
      if Object.const_defined?(OmnitureLogger) && controller.class.class_variable_defined?('@@omnilog')
        controller.class.omnilog.report(controller, 'js', self)
      end
      output = <<-JS
        <script type="text/javascript">
          var s_account = "#{OmnitureClient::account}";
        </script>
        <script type="text/javascript" src="/javascripts/#{OmnitureClient::js_include}"></script>
        <script type="text/javascript">
          #{vars_to_js}
          #{js_vars.join("\n")}
          var s_code=s.t(); if(s_code)document.write(s_code);
          #{js_events.join("\n")}
        </script>
      JS
    end

    def no_js(ssl = false)
      output = <<-HTML
        <noscript>
          <img src="#{base_url(ssl)}/b/ss/#{suite}/1/#{OmnitureClient::version}--NS/0" height="1" width="1" border="0" alt="" />
        </noscript>
      HTML
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

    def vars_to_js
      if Object.const_defined?(OmnitureLogger) && controller.class.class_variable_defined?('@@omnilog')
        controller.class.omnilog.report(controller, 'vars_to_js', self)
      end
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

    def suite
      OmnitureClient::suite.is_a?(Array) ? OmnitureClient::suite.join(',') : OmnitureClient::suite
    end

    def base_url(ssl)
      ssl == :ssl ? OmnitureClient::ssl_url : OmnitureClient::base_url
    end

    def var_to_query(var)
      "#{ CGI::escape(var.name) }=#{ CGI::escape(var.value) }" if var
    end

    def var_to_js(var)
      %Q{\t#{OmnitureClient::var_prefix + '.' if OmnitureClient::var_prefix}#{var.name}="#{var.value}"} if var
    end
  end
end
