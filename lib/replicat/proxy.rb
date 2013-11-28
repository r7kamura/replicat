require "active_support/core_ext/object/try"

module Replicat
  class Proxy
    REPLICABLE_METHOD_NAMES = %w[select_all schema_cache]
    REPLICABLE_METHOD_NAMES_REGEXP = /\A#{Regexp.union(REPLICABLE_METHOD_NAMES)}\z/

    attr_accessor :current_connection_name

    attr_writer :index

    def initialize(model_class)
      @model_class = model_class
    end

    private

    def method_missing(method_name, *args, &block)
      if current_connection_name
        current_connection.send(method_name, *args, &block)
      else
        connection_by_method_name(method_name).send(method_name, *args, &block)
      end
    end

    def connection_by_method_name(method_name)
      REPLICABLE_METHOD_NAMES_REGEXP === method_name ? slave_connection : master_connection
    end

    def current_connection
      if current_connection_name.to_s == "master"
        master_connection
      else
        slave_connection_pool_table[current_connection_name.to_s].try(:connection) or raise_connection_not_found
      end
    end

    def master_connection
      @model_class.connection_without_proxy
    end

    def slave_connection
      slave_connection_pool.connection
    end

    def slave_connection_pool
      slave_connection_pool_table.values[slave_connection_index]
    end

    def slave_connection_pool_table
      @slave_connection_pools ||= @model_class.replications.inject({}) do |table, (name, configuration)|
        table.merge(name => ConnectionPoolCreater.create(configuration))
      end
    end

    def raise_connection_not_found
      raise Error, "connection #{current_connection_name} is not found"
    end

    def slave_connection_index
      index.tap { increment_slave_connection_index }
    end

    def increment_slave_connection_index
      self.index = (index + 1) % slave_connection_pool_table.size
    end

    def clear_query_cache
      master_connection.clear_query_cache
      slave_connection_pool_table.values.map {|pool| pool.connection.clear_query_cache }
    end

    def index
      @index ||= rand(slave_connection_pool_table.size)
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

    class Error < StandardError
    end
  end
end
