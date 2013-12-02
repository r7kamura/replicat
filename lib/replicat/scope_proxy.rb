module Replicat
  class ScopeProxy
    def initialize(attributes)
      @klass = attributes[:klass]
      @connection_name = attributes[:connection_name]
    end

    private

    def method_missing(method_name, *args, &block)
      result = using { @klass.send(method_name, *args, &block) }
      if result.respond_to?(:scoped)
        @klass = result
        self
      else
        result
      end
    end

    def using
      @klass.using(@connection_name) { yield }
    end
  end
end
