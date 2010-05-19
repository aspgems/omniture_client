module OmnitureClient
  class Base
    
    class << self
      attr_reader :meta_vars
      @@controller = nil
      
      def var(name, delimiter = ',', &block)
        @meta_vars ||= []
        meta_var = instance_eval("@#{name} ||= OmnitureClient::MetaVar.new('#{name}', '#{delimiter}')")
        meta_var.add_var(block)
        meta_vars << meta_var unless meta_vars.include?(meta_var)
        meta_var
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

    def add_var(name, value)
      self.class.var(name) do
        value
      end
    end
    
  end
end
