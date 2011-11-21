module OmnitureClient
  class Base
    include OmnitureClient::ClassLevelInheritableAttributes

    inheritable_attributes :meta_vars, :js_vars, :js_events

    DEFAULT_OPTIONS = { :delimiter => ',',
                        :unique => nil,
                        :expires_in => 0 }

    class << self

      def var(name, options = {}, &block)
        options = DEFAULT_OPTIONS.merge(options)

        @meta_vars ||= []
        meta_var = instance_eval("@#{name} ||= OmnitureClient::MetaVar.new(name, options)")
        meta_var.add_var(block || options[:copy])
        meta_vars << meta_var unless meta_vars.include?(meta_var)
        meta_var
      end

      def js_var(&block)
        @js_vars ||= []
        @js_vars << yield
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

      def find_var(name)
        meta_vars.find{ |meta| meta.name == name }
      end

      def for_action(name, &block)
        RAILS_DEFAULT_LOGGER.info("name = #{name}")
        yield
      end

    end

    include Printer

    attr_reader  :controller, :instance_meta_vars

    def initialize(controller)
      @controller = controller
      @instance_meta_vars = []
    end

    def instance_var(name, options = {}, &block)
      options = DEFAULT_OPTIONS.merge(options)

      meta_var = instance_eval("@#{name} ||= OmnitureClient::MetaVar.new(name, options)")
      meta_var.add_var(block)
      self.instance_meta_vars << meta_var unless instance_meta_vars.include?(meta_var)
      meta_var
    end

    def printer
      @printer ||= Printer.new(self)
    end

    def clear_instance_meta_vars
      if instance_meta_vars.present?
        instance_meta_vars.each do |var|
          instance_eval("@#{var.name} = nil")
        end
        instance_meta_vars = []
      end
    end

    def vars
      all_meta_vars = (self.class.meta_vars || []) + instance_meta_vars
      @vars ||= all_meta_vars.inject([]) do |vars, meta_var|
        vars << meta_var.value(controller, self) if meta_var
        vars
      end
    end

    def eval_var(name)
      meta_var = self.class.find_var(name)
      meta_var.value(controller, self).value if meta_var
    end

    def js_vars
      self.class.js_vars || []
    end

    def js_events
      self.class.js_events || []
    end

    def add_var(name, value, options = {})
      self.instance_var(name, options) do
        value
      end
    end

  end
end
