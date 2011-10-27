module OmnitureClient
  class Base

    DEFAULT_OPTIONS = { :delimiter => ',',
                        :unique => nil,
                        :expires_in => 0 }

    class << self
      attr_reader :meta_vars, :js_events
      @@controller = nil

      def var(name, options={}, &block)
        options = DEFAULT_OPTIONS.merge(options)

        @meta_vars ||= []
        meta_var = instance_eval("@#{name} ||= OmnitureClient::MetaVar.new('#{name}', '#{options[:delimiter]}', '#{options[:unique]}', #{options[:expires_in]})")
        meta_var.add_var(block)
        meta_vars << meta_var unless meta_vars.include?(meta_var)
        meta_var
      end

      def event(&block)
        @js_events ||= []
        @js_events << yield
      end

      def clear_meta_vars
        if @meta_vars.present?
          @meta_vars.each do |var|
            instance_eval("@#{var.name} = nil")
          end
          @meta_vars = []
        end
      end

      def for_action(name, &block)
        RAILS_DEFAULT_LOGGER.info("name = #{name}")
        yield
      end

    end

    include Printer

    attr_reader  :controller

    @meta_vars = []

    def initialize(controller)
      @controller = controller
    end

    def printer
      @printer ||= Printer.new(self)
    end

    def vars
      meta_vars = self.class.meta_vars || []
      @vars ||= meta_vars.inject([]) do |vars, meta_var|
        vars << meta_var.value(controller) if meta_var
        vars
      end
    end

    def js_events
      self.class.js_events || []
    end

    def add_var(name, value)
      self.class.var(name) do
        value
      end
    end

  end
end
