module Format
  module_function

  HourPluralizations = {ru: ["час", "часа", "часов"], en: ["hour", "hours"]}
  MinutePluralizations = {ru: ["минуту", "минуты", "минут"], en: ["minute", "minutes"]}
  
  def minutes_as_text(totalMinutes)
    hours = totalMinutes / 60;
    minutes = totalMinutes % 60;

    hoursString = "#{hours} #{Format.pluralize_word(hours, HourPluralizations)}"
    minutesString = "#{minutes} #{Format.pluralize_word(minutes, MinutePluralizations)}"


    if hours == 0
      minutesString
    elsif minutes == 0
      hoursString
    else
      "#{hoursString} #{minutesString}"
    end
  end
  
  def minutes_as_text_in_english(totalMinutes)
    hours = totalMinutes / 60;
    minutes = totalMinutes % 60;

    hoursString = "#{hours} #{Format.pluralize_word_in_english(hours, "hour", "hours")}"
    minutesString = "#{minutes} #{Format.pluralize_word_in_english(minutes, "minute", "minutes")}"


    if hours == 0
      minutesString
    elsif minutes == 0
      hoursString
    else
      "#{hoursString} #{minutesString}"
    end
  end
  
  def munutes_as_hhmm(minutesSinceMidnight)
    hours = minutesSinceMidnight / 60
    minutes = minutesSinceMidnight - hours * 60
    "%02i:%02i" % [hours, minutes]
  end
end
