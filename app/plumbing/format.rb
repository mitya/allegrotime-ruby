module Format
  module_function
  
  # f(х, "час", "часа", "часов")
  # f(х, "минута", "минуты", "минут")
  def pluralize_russian_word(number, word1, word2, word5)
    rem100 = number % 100;
    rem10 = number % 10;

    return word5 if (rem100 >= 11 && rem100 <= 19)
    return word5 if (rem10 == 0)
    return word1 if (rem10 == 1)
    return word2 if (rem10 >= 2 && rem10 <= 4)
    return word5 if (rem10 >= 5 && rem10 <= 9)
    return word5    
  end
  
  def minutes_as_text(totalMinutes)
    hours = totalMinutes / 60;
    minutes = totalMinutes % 60;

    hoursString = "#{hours} #{Format.pluralize_russian_word(hours, "час", "часа", "часов")}"
    minutesString = "#{minutes} #{Format.pluralize_russian_word(minutes, "минуту", "минуты", "минут")}"


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
