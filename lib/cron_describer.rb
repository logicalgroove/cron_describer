# frozen_string_literal: true

require_relative "cron_describer/version"

module CronDescriber
  class Error < StandardError; end

  def self.parse(cron_schedule)
    days_of_week = {0 => "Sunday", 1 => "Monday", 2 => "Tuesday", 3 => "Wednesday", 4 => "Thursday", 5 => "Friday", 6 => "Saturday"}

    minute, hour, day_of_month, month, day_of_week = cron_schedule.split(" ")

    time_string = ""
    day_string = ""
    month_string = ""

    # For time string
    if minute == "0" && hour != "*"
      time_string = "At #{hour.to_i}:00 AM"
    elsif minute != "*" && hour != "*"
      hour_val = hour.to_i
      time_string = "At #{hour_val > 12 ? hour_val - 12 : hour_val}:#{minute.to_i.to_s.rjust(2, '0')} #{hour_val >= 12 ? 'PM' : 'AM'}"
    elsif minute != "*" && hour == "*"
      time_string = "At #{minute.to_i} minutes past the hour"
    end

    # For day string
    if day_of_month != "*"
      day_string = ", on day #{day_of_month} of the month"
    elsif day_of_week =~ /\d#(\d)/
      week_num = $1
      day_num = day_of_week[0].to_i
      day_string = ", on the #{week_num.ordinalize} #{days_of_week[day_num]} of the month"
    elsif day_of_week != "*"
      day_num = day_of_week.to_i
      day_string = ", only on #{days_of_week[day_num]}"
    end

    # For month string
    if month != "*" && month != "*/1"
      month_string = ", every #{month.gsub('*/','')} months"
    end

    return "#{time_string}#{day_string}#{month_string}"
  end
end
