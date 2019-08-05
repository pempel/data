require_relative "../clauses/order"
require_relative "result_set"

module Datagate
  module Statements
    class Select
      def initialize(value, order: nil)
        @value = value.to_s.strip
        @clauses = [Clauses::Order.new(order)]
        @result_set = ResultSet.new
      end

      def execute
        if invalid?
          return @result_set
        end

        store = Store.new
        store.load

        records = @clauses.inject(store.records) do |records, clause|
          records = clause.apply(records)
        end

        rows = records.map do |record|
          column_names.map do |column_name|
            record[column_name.to_s.downcase]
          end
        end
        rows = rows.reject do |row|
          row.empty?
        end

        @result_set.rows = rows
        @result_set
      end

      private

      def column_names
        @_column_names ||= @value.split(",").map(&:strip)
      end

      def valid?
        column_names.each do |column_name|
          unless Store.new.has_column?(column_name)
            @result_set.error = "unknown column \"#{column_name}\""
            return false
          end
        end
        @clauses.each do |clause|
          if clause.invalid?
            @result_set.error = clause.error
            return false
          end
        end
        true
      end

      def invalid?
        !valid?
      end
    end
  end
end
