require "spec_helper"

RSpec.describe Autoterm::Tab do
  describe ".new" do
    it "stringifies name" do
      project = described_class.new :test, []

      expect(project.name).to eq("test")
    end

    it "handles a single command" do
      project = described_class.new "test", "rails s"

      expect(project.commands).to eq ["rails s"]
    end

    it "handles an array of commands"do
      project = described_class.new "test", ["rails s", "cd test"]

      expect(project.commands).to eq ["rails s", "cd test"]
    end

    it "handles an nested array of commands" do
      project = described_class.new "test", [
        "rails s", ["cd test"], [["rspec"], "foreman"]
      ]

      expect(project.commands).to eq ["rails s", "cd test", "rspec", "foreman"]
    end

    it "removes blank commands" do
      project = described_class.new "test", ["rails s", nil, "", [], "foreman"]

      expect(project.commands).to eq ["rails s", "foreman"]
    end
  end
end
