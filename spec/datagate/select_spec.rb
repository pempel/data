RSpec.describe Datagate::Select do
  include_context "store"

  context "#execute" do
    it "selects specific columns" do
      statement = described_class.new(" id, Project,  VERSION   ")

      result = statement.execute

      expect(result.to_s).to eq(
        "1,the hobbit,64\n"\
        "2,lotr,16\n"\
        "3,king kong,128\n"\
        "4,the hobbit,32"
      )
    end

    it "selects nothing if the columns are not specified" do
      statement = described_class.new("  ")

      result = statement.execute

      expect(result.to_s).to eq("")
    end

    context "with the ORDER clause" do
      it "works if the clause includes several columns" do
        order = " finish_Date, INTERNAL_BID   "
        statement = described_class.new("id,project", order: order)

        result = statement.execute

        expect(result.to_s).to eq(
          "2,lotr\n"\
          "3,king kong\n"\
          "4,the hobbit\n"\
          "1,the hobbit"
        )
      end

      it "works if the clause includes an unknown column" do
        order = "finish_Date, XXX"
        statement = described_class.new("id,project", order: order)

        result = statement.execute

        expect(result.to_s).to eq(
          "ERROR: unknown column \"XXX\" in the ORDER clause"
        )
      end
    end

    context "with the FILTER clause" do
      it "works if the clause includes an unquoted value" do
        filter = " FINISH_DATE  =  2006-07-22   "
        statement = described_class.new("id,project,finish_date", filter: filter)

        result = statement.execute

        expect(result.to_s).to eq("3,king kong,2006-07-22")
      end

      it "works if the clause includes an unquoted and a quoted value" do
        filter = "  PROJECT=\"the hobbit\"  OR   PROJECT    =  lotr  "
        statement = described_class.new("id,project,internal_bid", filter: filter)

        result = statement.execute

        expect(result.to_s).to eq(
          "1,the hobbit,45.0\n"\
          "2,lotr,15.0\n"\
          "4,the hobbit,22.8"
        )
      end

      it "works if the clause includes a complex boolean expression" do
        filter = "  PROJECT ='the hobbit' AND (  SHOT=01 OR SHOT  =  40)  "
        statement = described_class.new("id,project,shot", filter: filter)

        result = statement.execute

        expect(result.to_s).to eq(
          "1,the hobbit,01\n"\
          "4,the hobbit,40"
        )
      end

      it "works if the clause includes an incorrect boolean expression" do
        filter = "  PROJECT ='the hobbit' AND (  SHOT=01 OR SHOT  =  40  "
        statement = described_class.new("id,project,shot", filter: filter)

        result = statement.execute

        expect(result.to_s).to eq("ERROR: syntax error in the FILTER clause")
      end
    end
  end
end
