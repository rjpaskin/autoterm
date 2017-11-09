require "spec_helper"

RSpec.describe "Starting a project", type: :integration do
  context "when project config is valid" do
    let(:home) { File.expand_path("../../fixtures/.tmuxinator", __FILE__) }

    subject { run "autoterm simple" }

    context "when iTerm is already running" do
      before(:each) do
        osascript :activate_iterm, raise: true
      end

      it "opens a new window" do
        expect {
          subject
        }.to change { iterm.reload.windows.count }.by(1)
      end

      it "opens the correct tabs" do
        subject

        aggregate_failures do
          expect(iterm).to have_session 0,
            name: "tab_one",
            contents: [
              %r{printf "%s:%s" "\$PWD" "one"; echo},
              "#{home}:one"
            ]

          expect(iterm).to have_session 1,
            name: "tab_two",
            contents: [
              %r{printf "%s:%s" "\$PWD" "two-1"; echo},
              "#{home}:two-1",
              %r{printf "%s:%s" "\$PWD" "two-2"; echo},
              "#{home}:two-2"
            ]

          expect(iterm).to have_session 2,
            name: "tab_three",
            contents: [
              %r{printf "%s:%s" "\$PWD" "three"; echo},
              "#{home}:three"
            ]
        end
      end
    end

    context "when iTerm is not running" do
      before(:each) do
        osascript :kill_iterm, raise: true
      end

      it "runs the iTerm2 application" do
        subject

        aggregate_failures do
          expect(iterm).to be_running
          expect(iterm.windows.count).to be > 1
        end
      end
    end
  end
end
