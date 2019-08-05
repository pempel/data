require "bundler/setup"
require "datagate"
require "tempfile"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec.shared_context "empty store" do
  let(:store_file) do
    Tempfile.new("store.csv")
  end

  let(:store) do
    Datagate::Store.new(file_path: store_file.path)
  end

  after(:each) do
    store_file.unlink
  end
end

RSpec.shared_context "store" do
  let(:store_file) do
    Tempfile.new("store.csv").tap do |f|
      f << "ID|PROJECT|SHOT|VERSION|STATUS|FINISH_DATE|INTERNAL_BID|CREATED_DATE\n"
      f << "1|the hobbit|01|64|scheduled|2010-05-15|45.00|2010-04-01 13:35\n"
      f << "2|lotr|03|16|finished|2001-05-15|15.0|2001-04-01 06:47\n"
      f << "3|king kong|42|128|not required|2006-07-22|30.0|2006-10-15 09:14\n"
      f << "4|the hobbit|40|32|finished|2010-05-15|22.8|2010-03-22 01:10\n"
      f.close
    end
  end

  let(:store) do
    Datagate::Store.new(file_path: store_file.path)
  end

  after(:each) do
    store_file.unlink
  end
end
