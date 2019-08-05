module Datagate
  class ResultSet
    attr_accessor :rows, :error

    def initialize(rows = [], error = nil)
      @rows = rows
      @error = error
    end

    def to_s
      @error ? "ERROR: #{@error}" : @rows.map { |r| r.join(",") }.join("\n")
    end
  end
end
