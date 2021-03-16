# frozen_string_literal: true

require "spec_helper"

describe DenyListPolicy do
  subject { DenyListPolicy.new(user, deny_list) }

  let(:team_one) { create(:team) }
  let(:team_two) { create(:team) }
  let(:app_one) { create(:app, team: team_one) }
  let(:app_two) { create(:app, team: team_two) }

  let(:deny_list) { create(:deny_list, app: app_one) }

  context "normal user in team one" do
    let(:user) { create(:admin, team: team_one) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }

    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:destroy) }
    it "should be in scope" do
      deny_list
      expect(
        DenyListPolicy::Scope.new(user, DenyList).resolve
      ).to include(deny_list)
    end

    context "in read only mode" do
      before :each do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode) {
          true
        }
      end
      it { is_expected.not_to permit(:destroy) }
    end
  end

  context "unauthenticated user" do
    let(:user) { nil }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:destroy) }

    it "should be in scope" do
      deny_list
      expect(DenyListPolicy::Scope.new(user, DenyList).resolve).to be_empty
    end
  end

  context "normal user in team two" do
    let(:user) { create(:admin, team: team_two) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:destroy) }
    it "should not be in scope" do
      deny_list
      expect(
        DenyListPolicy::Scope.new(user, DenyList).resolve
      ).to_not include(deny_list)
    end
  end
end
