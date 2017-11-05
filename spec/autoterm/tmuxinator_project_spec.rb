require "spec_helper"
require "erb"

RSpec.describe Autoterm::TmuxinatorProject do
  let(:home) { "spec/fixtures" }

  let(:config) do
    content = File.read("#{home}/.tmuxinator/test.yml")

    YAML.load(ERB.new(content, nil, "-").result binding)
  end

  before(:each) do
    allow(ENV).to receive(:[]).with("HOME").and_return(home)
  end

  describe ".from_yaml_file" do
    context "when project file exists" do
      it "creates new project with config from YAML file" do
        project = described_class.from_yaml_file("test")

        expect(project.config).to eq(config)
      end
    end

    context "when project file doesn't exist" do
      it "raises ProjectNotFoundError" do
        expect {
          described_class.from_yaml_file("wrong")
        }.to raise_error(
          Autoterm::ProjectNotFoundError,
          %r{Unable to find project 'wrong', tried to load #{home}/.tmuxinator/wrong.yml}
        )
      end
    end

    context "when project file has invalid YAML" do
      it "raises ParseError" do
        expect {
          described_class.from_yaml_file("invalid_yaml")
        }.to raise_error(
          Autoterm::ParseError, /invalid_yaml.+Psych::SyntaxError/m
        )
      end
    end

    context "when project file has invalid ERB" do
      it "raises ParseError" do
        expect {
          described_class.from_yaml_file("invalid_erb")
        }.to raise_error(
          Autoterm::ParseError, /invalid_erb.+SyntaxError/m
        )
      end
    end
  end

  describe "#root" do
    it "returns root from config" do
      project = described_class.new(config)

      expect(project.root).to eq("~/test")
    end
  end

  describe "#tabs" do
    subject(:project) { described_class.new(config) }

    it "handles key => command values" do
      expect(project.tabs.values_at 3, 5, 6, 7).to eq [
        Autoterm::Tab.new("database", "bundle exec rails db"),
        Autoterm::Tab.new("logs", "tail -f log/development.log"),
        Autoterm::Tab.new("console", "bundle exec rails c"),
        Autoterm::Tab.new("capistrano", "")
      ]
    end

    it "handles multiple commands per tab" do
      expect(project.tabs.values_at 1).to eq [
        Autoterm::Tab.new("shell", ["git pull", "git merge"])
      ]
    end

    it "handles duplicate tab names" do
      expect(project.tabs.values_at 4, 8).to eq [
        Autoterm::Tab.new("server", "bundle exec rails s"),
        Autoterm::Tab.new("server", "ssh user@example.com")
      ]
    end

    it "handles tabs/windows with panes" do
      expect(project.tabs.values_at 0, 2).to eq [
        Autoterm::Tab.new("editor", [
          %{echo "I get run in each pane, before each pane command!"},
          "vim",
          "top",
          "ssh server",
          %{echo "Hello"}
        ]),
        Autoterm::Tab.new("guard", [
          %{echo "I get run in each pane."},
          %{echo "Before each pane command!"}
        ])
      ]
    end
  end
end

