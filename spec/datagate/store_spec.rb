require "tempfile"

RSpec.describe Store do
  context "#import" do
    it "imports data into the store" do
      store = described_class.new
      line = "the hobbit|01|64|scheduled|2010-05-15|45.00|2010-04-01 13:35"

      store.import(line)

      expect(store.records.count).to eq(1)
      expect(store.records[0].to_h).to include({
        id: 1,
        project: "the hobbit",
        shot: "01",
        version: 64,
        status: "scheduled",
        finish_date: "2010-05-15",
        internal_bid: 45.0,
        created_date: "2010-04-01 13:35"
      })
    end

    it "overwrites the same logical data (PROJECT + SHOT + VERSION)" do
      store = described_class.new
      line_1 = "king kong|42|128|scheduled|2006-07-22|45.00|2006-08-04 07:22"
      line_2 = "lotr|03|16|finished|2001-05-15|15.00|2001-04-01 06:30"
      line_3 = "king kong|42|128|not required|2006-07-22|30.00|2006-10-15 09:14"

      store.import(line_1)
      store.import(line_2)
      store.import(line_3)

      expect(store.records.count).to eq(2)
      expect(store.records[0].to_h).to include({
        id: 1,
        project: "king kong",
        shot: "42",
        version: 128,
        status: "not required",
        finish_date: "2006-07-22",
        internal_bid: 30.0,
        created_date: "2006-10-15 09:14"
      })
      expect(store.records[1].to_h).to include({
        id: 2,
        project: "lotr",
        shot: "03",
        version: 16,
        status: "finished",
        finish_date: "2001-05-15",
        internal_bid: 15.0,
        created_date: "2001-04-01 06:30"
      })
    end
  end

  context "#load" do
    let(:store_file) do
      Tempfile.new("store.csv").tap do |f|
        f << "ID|PROJECT|SHOT|VERSION|STATUS|FINISH_DATE|INTERNAL_BID|CREATED_DATE\n"
        f << "1|the hobbit|01|64|scheduled|2010-05-15|45.00|2010-04-01 13:35\n"
        f.close
      end
    end

    after(:each) do
      store_file.unlink
    end

    it "loads all data from a file" do
      store = described_class.new(file_path: store_file.path)

      store.load

      expect(store.records.count).to eq(1)
      expect(store.records[0].to_h).to include({
        id: 1,
        project: "the hobbit",
        shot: "01",
        version: 64,
        status: "scheduled",
        finish_date: "2010-05-15",
        internal_bid: 45.0,
        created_date: "2010-04-01 13:35"
      })
    end
  end

  context "#dump" do
    let(:store_file) do
      Tempfile.new("store.csv")
    end

    after(:each) do
      store_file.unlink
    end

    it "dumps all data into a file" do
      store = described_class.new(file_path: store_file.path)
      line = "the hobbit|01|64|scheduled|2010-05-15|45.00|2010-04-01 13:35"

      store.import(line)
      store.dump

      expect(store_file.read).to eq(
        "ID|PROJECT|SHOT|VERSION|STATUS|FINISH_DATE|INTERNAL_BID|CREATED_DATE\n"\
        "1|the hobbit|01|64|scheduled|2010-05-15|45.0|2010-04-01 13:35\n"
      )
    end
  end
end
