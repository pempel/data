module Datagate
  class Store
    Record = Struct.new(
      :id,
      :project,
      :shot,
      :version,
      :status,
      :finish_date,
      :internal_bid,
      :created_date
    ) do
      def self.to_param(name, value)
        name = name.to_s.strip.downcase
        value = value.to_s.strip.gsub(/\A"|"\Z/, '').gsub(/\A'|'\Z/, '')
        case name
        when "id", "version" then value.to_i
        when "internal_bid" then value.to_f
        else "\"#{value}\""
        end
      end

      def initialize(id, pro, sho, ver, sta, fin, int, cre)
        super(id.to_i, pro, sho, ver.to_i, sta, fin, int.to_f, cre)
      end

      def primary_key
        "#{project}-#{shot}-#{version}"
      end
    end
  end
end
