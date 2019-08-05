require_relative "base"

module Datagate
  module Clauses
    class Order < Base
      def valid?
        column_names.each do |column_name|
          unless Store.has_column?(column_name)
            @error = "unknown column \"#{column_name}\" in the ORDER clause"
            return false
          end
        end
        true
      end

      def apply(records = [])
        valid? ? records.sort_by { |r| column_values(r) } : records
      end

      private

      def column_names
        @_column_names ||= @value.split(",").map(&:strip)
      end

      def column_values(record)
        column_names.map do |column_name|
          eval("record[column_name.downcase]")
        end
      end
    end
  end
end
