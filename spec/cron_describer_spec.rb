# frozen_string_literal: true

require "cron_describer"
require "spec_helper"

RSpec.describe CronDescriber do
  it "has a version number" do
    expect(CronDescriber::VERSION).not_to be nil
  end

  describe ".parse" do
    context "basic time formats" do
      it "parses basic hour and minute" do
        expect(CronDescriber.parse("30 6 1 */3 *")).to eq("At 6:30 AM, on day 1 of the month, every 3 months")
      end

      it "handles midnight correctly" do
        expect(CronDescriber.parse("0 0 * * *")).to eq("At 12:00 AM")
      end

      it "handles noon correctly" do
        expect(CronDescriber.parse("0 12 * * *")).to eq("At 12:00 PM")
      end

      it "handles afternoon times correctly" do
        expect(CronDescriber.parse("30 15 * * *")).to eq("At 3:30 PM")
      end

      it "handles late night times correctly" do
        expect(CronDescriber.parse("0 23 * * *")).to eq("At 11:00 PM")
      end
    end

    context "wildcard handling" do
      it "handles every minute" do
        expect(CronDescriber.parse("* * * * *")).to eq("Every minute")
      end

      it "handles every minute during specific hour" do
        expect(CronDescriber.parse("* 9 * * *")).to eq("Every minute during 9:00 AM")
      end

      it "handles specific minute every hour" do
        expect(CronDescriber.parse("15 * * * *")).to eq("At 15 minutes past the hour")
      end
    end

    context "step values" do
      it "handles minute steps" do
        expect(CronDescriber.parse("*/5 * * * *")).to eq("Every 5 minutes")
      end

      it "handles hour steps" do
        expect(CronDescriber.parse("0 */2 * * *")).to eq("Every 2 hours")
      end

      it "handles month steps" do
        expect(CronDescriber.parse("0 0 1 */3 *")).to eq("At 12:00 AM, on day 1 of the month, every 3 months")
      end
    end

    context "ranges" do
      it "handles day of week ranges" do
        expect(CronDescriber.parse("0 9 * * 1-5")).to eq("At 9:00 AM, only on Monday through Friday")
      end

      it "handles month ranges" do
        expect(CronDescriber.parse("0 0 1 6-8 *")).to eq("At 12:00 AM, on day 1 of the month, June through August")
      end
    end

    context "lists" do
      it "handles day of week lists" do
        expect(CronDescriber.parse("0 9 * * 1,3,5")).to eq("At 9:00 AM, only on Monday, Wednesday, Friday")
      end

      it "handles minute lists" do
        expect(CronDescriber.parse("0,15,30,45 * * * *")).to eq("At 0, 15, 30, 45 minutes past the hour")
      end

      it "handles hour lists" do
        expect(CronDescriber.parse("0 9,13,17 * * *")).to eq("At 9:00 AM, 1:00 PM, 5:00 PM")
      end
    end

    context "day of week edge cases" do
      it "handles day 7 as Sunday" do
        expect(CronDescriber.parse("0 9 * * 7")).to eq("At 9:00 AM, only on Sunday")
      end

      it "handles both 0 and 7 for Sunday" do
        expect(CronDescriber.parse("0 9 * * 0,7")).to eq("At 9:00 AM, only on Sunday, Sunday")
      end
    end

    context "complex expressions" do
      it "handles complex weekday pattern" do
        expect(CronDescriber.parse("30 8-17 * * 1-5")).to eq("At 30 minutes past the hour, only on Monday through Friday")
      end
    end
  end

  describe ".validate_cron_field" do
    it "validates minute field correctly" do
      expect(CronDescriber.validate_cron_field("30", 0, 59, "minute")).to be true
      expect(CronDescriber.validate_cron_field("60", 0, 59, "minute")).to be false
      expect(CronDescriber.validate_cron_field("*/5", 0, 59, "minute")).to be true
      expect(CronDescriber.validate_cron_field("0-30", 0, 59, "minute")).to be true
      expect(CronDescriber.validate_cron_field("0,15,30,45", 0, 59, "minute")).to be true
    end

    it "validates hour field correctly" do
      expect(CronDescriber.validate_cron_field("12", 0, 23, "hour")).to be true
      expect(CronDescriber.validate_cron_field("24", 0, 23, "hour")).to be false
    end
  end

  describe "error handling" do
    it "raises error for nil input" do
      expect { CronDescriber.parse(nil) }.to raise_error(CronDescriber::Error, "Cron schedule cannot be nil or empty")
    end

    it "raises error for empty input" do
      expect { CronDescriber.parse("") }.to raise_error(CronDescriber::Error, "Cron schedule cannot be nil or empty")
    end

    it "raises error for insufficient fields" do
      expect { CronDescriber.parse("30 6 1") }.to raise_error(CronDescriber::Error, "Invalid cron format. Expected 5 fields (minute hour day_of_month month day_of_week)")
    end

    it "raises error for invalid minute" do
      expect { CronDescriber.parse("60 6 1 1 1") }.to raise_error(CronDescriber::Error, "Invalid minute field: 60")
    end

    it "raises error for invalid hour" do
      expect { CronDescriber.parse("30 24 1 1 1") }.to raise_error(CronDescriber::Error, "Invalid hour field: 24")
    end

    it "raises error for invalid day of month" do
      expect { CronDescriber.parse("30 6 32 1 1") }.to raise_error(CronDescriber::Error, "Invalid day of month field: 32")
    end

    it "raises error for invalid month" do
      expect { CronDescriber.parse("30 6 1 13 1") }.to raise_error(CronDescriber::Error, "Invalid month field: 13")
    end

    it "raises error for invalid day of week" do
      expect { CronDescriber.parse("30 6 1 1 8") }.to raise_error(CronDescriber::Error, "Invalid day of week field: 8")
    end
  end
end
