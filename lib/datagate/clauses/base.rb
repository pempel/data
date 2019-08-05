module Datagate
  module Clauses
    class Base
      attr_reader :error

      def initialize(value = nil)
        @value = value.to_s.strip
        @error = nil
      end

      def valid?
        true
      end

      def apply(records = [])
        records
      end
    end
  end
end
