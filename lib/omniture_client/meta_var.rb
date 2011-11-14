module OmnitureClient
  class MetaVar
    attr_reader :name, :delimiter, :cache_key, :expires_in, :only, :except
    attr_accessor :value_procs

    def initialize(name, options = {})
      @name = name
      @value_procs = []
      @delimiter = options[:delimiter]
      @cache_key = "omniture/#{name}/#{options[:unique]}"
      @expires_in = options[:expires_in]
      @only = Array(options[:only]).map(&:to_s).to_set if options[:only]
      @except = Array(options[:except]).map(&:to_s).to_set if options[:except]
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
      if (only && !only.include?(scope.action_name)) ||
         (except && except.include?(scope.action_name))
        Var.new(name, nil)
      else
        values = value_procs.map do |p|
          p = [p] if p.is_a?(Symbol)
          if p.is_a?(Array)
            value = p.map{ |v| reporter.eval_var(v) }.compact.first
          else
            scope.instance_eval(&p)
          end
        end
        Var.new(name, values.flatten.compact.uniq.join(delimiter))
      end
    end

  end
end
