require "spec_helper"

RSpec.describe Autoterm::CLI do
  class FakeSystemExit < StandardError; end

  def ignore_fake_system_exit
    allow(Kernel).to receive(:exit).and_raise(FakeSystemExit)

    yield
  rescue FakeSystemExit
    # do nothing
  end

  describe ".run" do
    before(:each) do
      # prevent errors being output during specs
      allow($stderr).to receive(:puts)

      allow(ENV).to receive(:[]).with("HOME").and_return("spec/fixtures")
    end

    context "without a project name" do
      subject { described_class.run [] }

      it "outputs error message" do
        expect {
          ignore_fake_system_exit { subject }
        }.to output("Provide a project name\n").to_stderr
      end

      it "exits with error status" do
        expect {
          subject
        }.to exit_with_code(1)
      end
    end

    context "with a project name" do
      let(:project_name) { "test" }

      subject { described_class.run [project_name] }

      context "and no errors raised" do
        let(:project) { double("project") }
        let(:applescript) { double("applescript", run: true) }

        before(:each) do
          allow(Autoterm::TmuxinatorProject).to receive(:from_yaml_file)
            .with("test").and_return(project)

          allow(Autoterm::Applescript).to receive(:new).and_return(applescript)
        end

        it "executes the applescript for the given project" do
          subject

          aggregate_failures do
            expect(Autoterm::Applescript).to have_received(:new).with(project)
            expect(applescript).to have_received(:run)
          end
        end
      end

      context "when an error is raised" do
        before(:each) do
          expect(Autoterm::TmuxinatorProject).to receive(:from_yaml_file)
            .and_raise(
              Autoterm::ProjectNotFoundError.new project_name, "test.yml"
            )
        end

        it "outputs error message" do
          expect {
            ignore_fake_system_exit { subject }
          }.to output(
            "Unable to find project 'test', tried to load test.yml\n"
          ).to_stderr
        end

        it "exits with error status" do
          expect {
            subject
          }.to exit_with_code(1)
        end
      end
    end
  end
end
