require_relative "clauses/filter"
require_relative "clauses/order"
require_relative "result"

module Datagate
  class Select
    def initialize(value, filter: nil, order: nil)
      @value = value.to_s.strip
      @clauses = [Clauses::Filter.new(filter), Clauses::Order.new(order)]
      @result = Result.new
    end

    def execute
      unless valid?
        return @result
      end

      store = Store.new
      store.load

      records = @clauses.inject(store.records) do |records, clause|
        records = clause.apply(records)
      end

      rows = records.map do |record|
        column_names.map do |column_name|
          record[column_name.downcase]
        end
      end
      rows = rows.reject do |row|
        row.empty?
      end

      @result.rows = rows
      @result
    end

    private

    def column_names
      @_column_names ||= @value.split(",").map(&:strip)
    end

    def valid?
      column_names.each do |column_name|
        unless Store.has_column?(column_name)
          @result.error = "unknown column \"#{column_name}\""
          return false
        end
      end
      @clauses.each do |clause|
        unless clause.valid?
          @result.error = clause.error
          return false
        end
      end
      true
    end
  end
end
