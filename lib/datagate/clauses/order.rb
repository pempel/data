module Datagate
  module Clauses
    class Order
      attr_reader :error

      def initialize(value = nil)
        @value = value.to_s.strip
        @error = nil
      end

      def valid?
        column_names.each do |column_name|
          unless Store.new.has_column?(column_name)
            @error = "unknown column \"#{column_name}\" in the ORDER clause"
            return false
          end
        end
        true
      end

      def invalid?
        !valid?
      end

      def apply(records = [])
        invalid? ? records : records.sort_by { |r| column_values(r) }
      end

      private

      def column_names
        @_column_names ||= @value.split(",").map(&:strip)
      end

      def column_values(record)
        column_names.map do |column_name|
          eval("record[column_name.to_s.downcase]")
        end
      end
    end
  end
end
