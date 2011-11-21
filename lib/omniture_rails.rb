module OmnitureClient
  module ActionControllerMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def reports_to_omniture(options = {})
        include InstanceMethods
        before_filter :set_reporter, options
        before_filter :assign_flash_vars, options
        after_filter :clean_flash_vars, options
        attr_accessor :reporter
      end
    end

    module InstanceMethods
      def omniture_flash
        flash[:omniture] ||= {}
      end

      def omniture_url
        ssl = :ssl if request.ssl? && OmnitureClient::ssl_url
        reporter.url(ssl)
      end

      def omniture_js
        reporter.js
      end

      def omniture_no_js
        ssl = :ssl if request.ssl? && OmnitureClient::ssl_url
        reporter.no_js(ssl)
      end

      def omniture_raw
        reporter.raw
      end

      private

      def set_reporter
        @reporter ||= begin
          self.class.name.sub('Controller', 'Reporter').constantize.new(self)
        rescue NameError
          BasicReporter.new(self)
        end
      end

      def assign_flash_vars
        reporter.clear_instance_meta_vars unless omniture_flash.empty?
        omniture_flash.each do |name, value|
          reporter.add_var(name, value)
        end
      end

      def clean_flash_vars
        session['flash'].delete(:omniture) if session['flash'] && omniture_flash.empty?
      end
    end
  end
end

ActionController::Base.send(:include, OmnitureClient::ActionControllerMethods) if defined?(ActionController::Base)
