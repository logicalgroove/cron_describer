# frozen_string_literal: true

require_relative "cron_describer/version"

module CronDescriber
  class Error < StandardError; end

  def self.ordinalize(number)
    num = number.to_i
    case num % 100
    when 11, 12, 13
      "#{num}th"
    else
      case num % 10
      when 1
        "#{num}st"
      when 2
        "#{num}nd"
      when 3
        "#{num}rd"
      else
        "#{num}th"
      end
    end
  end

  def self.parse_field(field, field_type)
    return "*" if field == "*"
    
    # Handle step values (e.g., "*/5", "10-30/5")
    if field.include?("/")
      base, step = field.split("/")
      step_val = step.to_i
      
      if base == "*"
        case field_type
        when :minute
          return "every #{step_val} minutes"
        when :hour
          return "every #{step_val} hours"
        when :day_of_month
          return "every #{step_val} days"
        when :month
          return "every #{step_val} months"
        when :day_of_week
          return "every #{step_val} days of the week"
        end
      elsif base.include?("-")
        start_val, end_val = base.split("-").map(&:to_i)
        case field_type
        when :minute
          return "every #{step_val} minutes from #{start_val} to #{end_val}"
        when :hour
          return "every #{step_val} hours from #{start_val} to #{end_val}"
        else
          return "every #{step_val} from #{start_val} to #{end_val}"
        end
      end
    end
    
    # Handle ranges (e.g., "1-5")
    if field.include?("-") && !field.include?("/")
      start_val, end_val = field.split("-").map(&:to_i)
      case field_type
      when :day_of_week
        days = {0 => "Sunday", 1 => "Monday", 2 => "Tuesday", 3 => "Wednesday", 4 => "Thursday", 5 => "Friday", 6 => "Saturday", 7 => "Sunday"}
        return "#{days[start_val]} through #{days[end_val]}"
      when :month
        months = {1 => "January", 2 => "February", 3 => "March", 4 => "April", 5 => "May", 6 => "June", 
                  7 => "July", 8 => "August", 9 => "September", 10 => "October", 11 => "November", 12 => "December"}
        return "#{months[start_val]} through #{months[end_val]}"
      else
        return "#{start_val}-#{end_val}"
      end
    end

    # Handle lists (e.g., "0,15,30,45")
    if field.include?(",")
      values = field.split(",").map(&:to_i)
      case field_type
      when :day_of_week
        days = {0 => "Sunday", 1 => "Monday", 2 => "Tuesday", 3 => "Wednesday", 4 => "Thursday", 5 => "Friday", 6 => "Saturday", 7 => "Sunday"}
        day_names = values.map { |v| days[v] }.compact
        return day_names.join(", ")
      when :hour
        return values.map { |v| 
          display_hour = v > 12 ? v - 12 : (v == 0 ? 12 : v)
          "#{display_hour}:00 #{v >= 12 ? 'PM' : 'AM'}"
        }.join(", ")
      when :minute
        return values.join(", ")
      else
        return values.join(", ")
      end
    end

    field
  end

  def self.validate_cron_field(field, min_val, max_val, field_name)
    return true if field == "*"
    
    # Handle step values
    if field.include?("/")
      base, step = field.split("/")
      return false if step.to_i <= 0
      return validate_cron_field(base, min_val, max_val, field_name) if base != "*"
      return true
    end
    
    # Handle ranges
    if field.include?("-")
      start_val, end_val = field.split("-").map(&:to_i)
      return false if start_val < min_val || end_val > max_val || start_val > end_val
      return true
    end
    
    # Handle lists
    if field.include?(",")
      values = field.split(",").map(&:to_i)
      return values.all? { |v| v >= min_val && v <= max_val }
    end
    
    # Handle single values
    val = field.to_i
    val >= min_val && val <= max_val
  end

  def self.parse(cron_schedule)
    raise Error, "Cron schedule cannot be nil or empty" if cron_schedule.nil? || cron_schedule.strip.empty?
    
    fields = cron_schedule.strip.split(/\s+/)
    raise Error, "Invalid cron format. Expected 5 fields (minute hour day_of_month month day_of_week)" unless fields.length == 5
    
    minute, hour, day_of_month, month, day_of_week = fields
    
    # Validate each field
    raise Error, "Invalid minute field: #{minute}" unless validate_cron_field(minute, 0, 59, "minute")
    raise Error, "Invalid hour field: #{hour}" unless validate_cron_field(hour, 0, 23, "hour") 
    raise Error, "Invalid day of month field: #{day_of_month}" unless validate_cron_field(day_of_month, 1, 31, "day_of_month")
    raise Error, "Invalid month field: #{month}" unless validate_cron_field(month, 1, 12, "month")
    raise Error, "Invalid day of week field: #{day_of_week}" unless validate_cron_field(day_of_week, 0, 7, "day_of_week")
    
    days_of_week = {0 => "Sunday", 1 => "Monday", 2 => "Tuesday", 3 => "Wednesday", 4 => "Thursday", 5 => "Friday", 6 => "Saturday", 7 => "Sunday"}

    time_string = ""
    day_string = ""
    month_string = ""

    # For time string
    if minute == "0" && hour != "*" && !hour.include?(",") && !hour.include?("-") && !hour.include?("/")
      hour_val = hour.to_i
      time_string = "At #{hour_val > 12 ? hour_val - 12 : (hour_val == 0 ? 12 : hour_val)}:00 #{hour_val >= 12 ? 'PM' : 'AM'}"
    elsif minute != "*" && hour != "*" && !minute.include?(",") && !hour.include?(",") && !hour.include?("-") && !hour.include?("/") && !minute.include?("-") && !minute.include?("/")
      hour_val = hour.to_i
      display_hour = hour_val > 12 ? hour_val - 12 : (hour_val == 0 ? 12 : hour_val)
      time_string = "At #{display_hour}:#{minute.to_i.to_s.rjust(2, '0')} #{hour_val >= 12 ? 'PM' : 'AM'}"
    elsif minute != "*" && hour == "*"
      parsed_minute = parse_field(minute, :minute)
      if parsed_minute.include?("every")
        time_string = "#{parsed_minute.capitalize}"
      elsif minute.include?(",")
        time_string = "At #{parsed_minute} minutes past the hour"
      else
        time_string = "At #{minute.to_i} minutes past the hour"
      end
    elsif minute == "*" && hour != "*" && !hour.include?(",") && !hour.include?("-") && !hour.include?("/")
      hour_val = hour.to_i
      display_hour = hour_val > 12 ? hour_val - 12 : (hour_val == 0 ? 12 : hour_val)
      time_string = "Every minute during #{display_hour}:00 #{hour_val >= 12 ? 'PM' : 'AM'}"
    elsif minute == "*" && hour == "*"
      time_string = "Every minute"
    elsif minute == "0" && hour.include?("/")
      parsed_hour = parse_field(hour, :hour)
      time_string = "#{parsed_hour.capitalize}"
    elsif minute == "0" && hour.include?(",")
      parsed_hour = parse_field(hour, :hour)
      time_string = "At #{parsed_hour}"
    elsif minute != "*" && hour.include?("-") && !minute.include?(",") && !minute.include?("-") && !minute.include?("/")
      time_string = "At #{minute.to_i} minutes past the hour"
    end

    # For day string
    if day_of_month != "*"
      day_string = ", on day #{day_of_month} of the month"
    elsif day_of_week =~ /\d#(\d)/
      week_num = $1
      day_num = day_of_week[0].to_i
      day_string = ", on the #{ordinalize(week_num)} #{days_of_week[day_num]} of the month"
    elsif day_of_week != "*"
      parsed_dow = parse_field(day_of_week, :day_of_week)
      if parsed_dow.include?(",") || parsed_dow.include?("through")
        day_string = ", only on #{parsed_dow}"
      else
        day_num = day_of_week.to_i
        day_string = ", only on #{days_of_week[day_num]}"
      end
    end

    # For month string
    if month != "*"
      parsed_month = parse_field(month, :month)
      if parsed_month != month && parsed_month != "*"
        month_string = ", #{parsed_month}"
      elsif month.include?("/") && month != "*/1"
        month_string = ", #{parsed_month}"
      end
    end

    return "#{time_string}#{day_string}#{month_string}"
  end
end
