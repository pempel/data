require_relative "base"

module Datagate
  module Clauses
    class Filter < Base
      def valid?
        column_names.each do |column_name|
          unless Store.has_column?(column_name)
            @error = "unknown column \"#{column_name}\" in the FILTER clause"
            return false
          end
        end
        record = Store::Record.new(
          "1",
          "the hobbit",
          "01",
          "64",
          "scheduled",
          "2010-05-15",
          "45.00",
          "2010-04-01 13:35"
        )
        begin
          evaluate_filter_criteria(record)
          true
        rescue SyntaxError
          @error = "syntax error in the FILTER clause"
          false
        end
      end

      def apply(records = [])
        valid? ? records.select { |r| evaluate_filter_criteria(r) } : records
      end

      private

      def column_names
        @_column_names ||= begin
          @value
            .gsub(/ AND /i, " ")
            .gsub(/ OR /i, " ")
            .gsub("(", "")
            .gsub(")", "")
            .gsub(/[ ]*=[ ]*/i, "=")
            .scan(/([^ ]*)=[^ ]*/)
            .flatten
        end
      end

      def filter_criteria
        @_filter_criteria ||= begin
          result = Store.column_names.inject(@value) do |result, name|
            pattern_with_quotes = /#{name}[ ]*=[ '"]*(.*)['"]/i
            pattern_without_quotes = /#{name}[ ]*=[ ]*([^ )]*)/i
            patterns = [pattern_with_quotes, pattern_without_quotes]
            patterns.each do |pattern|
              if result.match?(pattern)
                new_name = "record[\"#{name.downcase}\"]"
                new_value = Store::Record.to_param(name, "\\1")
                result = result.gsub(pattern, "#{new_name} == #{new_value}")
              end
            end
            result
          end
          result = result.gsub(/ AND /i, " && ")
          result = result.gsub(/ OR /i, " || ")
          result
        end
      end

      def evaluate_filter_criteria(record)
        filter_criteria.empty? ? true : eval(filter_criteria)
      end
    end
  end
end
