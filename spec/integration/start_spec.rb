require "spec_helper"

RSpec.describe "Starting a project", type: :integration do
  context "when project config is valid" do
    let(:home) { File.expand_path("../../fixtures/.tmuxinator", __FILE__) }

    subject { run "autoterm simple" }

    context "when iTerm is already running" do
      it "opens a new window" do
        expect {
          subject
        }.to change { iterm.reload.windows.count }.by(1)
      end
    end
  end
end
