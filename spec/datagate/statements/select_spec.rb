RSpec.describe Datagate::Statements::Select do
  include_context "store"

  context "#execute" do
    it "selects specific columns" do
      statement = described_class.new(" id, Project,  VERSION   ")

      result_set = statement.execute

      expect(result_set.to_s).to eq(
        "1,the hobbit,64\n"\
        "2,lotr,16\n"\
        "3,king kong,128\n"\
        "4,the hobbit,32"
      )
    end

    it "selects nothing if the columns are not specified" do
      statement = described_class.new("  ")

      result_set = statement.execute

      expect(result_set.to_s).to eq("")
    end

    it "works with the ORDER clause" do
      order = " finish_Date, INTERNAL_BID   "
      statement = described_class.new("id,project", order: order)

      result_set = statement.execute

      expect(result_set.to_s).to eq(
        "2,lotr\n"\
        "3,king kong\n"\
        "4,the hobbit\n"\
        "1,the hobbit"
      )
    end
  end
end
