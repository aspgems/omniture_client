module OmnitureClient
  class MetaVar
    attr_reader :name, :delimiter, :cache_key, :expires_in
    attr_accessor :value_procs

    def initialize(name, options = {})
      @name = name
      @value_procs = []
      @delimiter = options[:delimiter]
      @cache_key = "omniture/#{name}/#{options[:unique]}"
      @expires_in = options[:expires_in]
    end

    def add_var(value_proc)
      value_procs << value_proc
    end

    # wrap up the value in a Var object and cache if needed
    def value(scope, reporter)
      if @expires_in > 0
        Rails.cache.fetch(@cache_key, :expires_in => @expires_in) do
          return_var(scope, reporter)
        end
      else
        return_var(scope, reporter)
      end
    end

    def return_var(scope, reporter)
      Var.new(name, value_procs.map{ |p| p.is_a?(Symbol) ? reporter.eval_var(p) : scope.instance_eval(&p) }.flatten.uniq.join(delimiter))
    end

  end
end
