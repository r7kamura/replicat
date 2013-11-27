module Replicat
  class Proxy
    REPLICABLE_METHOD_NAMES = %w[select_all schema_cache]
    REPLICABLE_METHOD_NAMES_REGEXP = /\A#{Regexp.union(REPLICABLE_METHOD_NAMES)}\z/

    def initialize(model_class)
      @model_class = model_class
    end

    private

    def method_missing(method_name, *args, &block)
      connection_by_method_name(method_name).send(method_name, *args, &block)
    end

    def connection_by_method_name(method_name)
      REPLICABLE_METHOD_NAMES_REGEXP === method_name ? slave_connection : master_connection
    end

    def master_connection
      @model_class.connection_without_proxy
    end

    def slave_connection
      slave_connection_pool.connection
    end

    def slave_connection_pool
      slave_connection_pool_table.values.sample
    end

    def slave_connection_pool_table
      @slave_connection_pools ||= @model_class.replications.inject({}) do |table, (name, configuration)|
        table.merge(name => ConnectionPoolCreater.create(configuration))
      end
    end

    # Creates database connection pool from configuration Hash table.
    class ConnectionPoolCreater
      def self.create(*args)
        new(*args).create
      end

      def initialize(configuration)
        @configuration = configuration.dup
      end

      def create
        ActiveRecord::ConnectionAdapters::ConnectionPool.new(
          ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(
            @configuration,
            nil,
          ).spec,
        )
      end
    end
  end
end
