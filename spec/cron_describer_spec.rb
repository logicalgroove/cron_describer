# frozen_string_literal: true

require "cron_describer"
require "spec_helper"

RSpec.describe CronDescriber do
  it "has a version number" do
    expect(CronDescriber::VERSION).not_to be nil
  end

  let(:cron_schedule) { "30 6 1 */3 *" }
  subject { CronDescriber.parse(cron_schedule) }

  describe ".parse" do
    let(:expected_description) { "At 6:30 AM, on day 1 of the month, every 3 months" }
    it "returns the correct description for a given cron scheduler" do
      expect(subject).to eq(expected_description)
    end
  end
end
