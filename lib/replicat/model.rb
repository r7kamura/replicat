module Replicat
  module Model
    def replicate(connection_name = nil)
      raise "You must set `connection_name` of this model class." if !connection_name && !defined?(Rails)
      include Replicat::Replicable
      self.connection_name = connection_name || Rails.env.to_s
    end
  end
end
