require "active_record"
require "active_support/concern"
require "active_support/core_ext/module/aliasing"

module Replicat
  module Replicable
    extend ActiveSupport::Concern

    included do
      class << self
        def proxy
          @proxy ||= Proxy.new(self)
        end

        alias_method_chain :connection, :proxy

        attr_accessor :connection_name
      end
    end

    module ClassMethods
      def connection_with_proxy
        if has_any_replication?
          proxy
        else
          connection_without_proxy
        end
      end

      def has_any_replication?
        has_configuration? && replications.present?
      end

      def has_configuration?
        !!configuration
      end

      def configuration
        connection_name && configurations[connection_name]
      end

      def replications
        configuration["replications"]
      end
    end
  end
end
