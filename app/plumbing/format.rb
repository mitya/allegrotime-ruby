module Format
  HourPluralizations = {ru: ["час", "часа", "часов"], en: ["hour", "hours"]}
  MinutePluralizations = {ru: ["минуту", "минуты", "минут"], en: ["minute", "minutes"]}
  
  module_function

  def pluralize_word(number, forms)
    case Device.language
      when 'ru' then pluralize_word_in_russian(number, *forms[:ru])
      when 'en' then pluralize_word_in_english(number, *forms[:en])
      else pluralize_word_in_russian(number, *forms[:ru])
    end
  end
  
  # f(х, "час", "часа", "часов")
  # f(х, "минута", "минуты", "минут")
  def pluralize_word_in_russian(number, word1, word2, word5)
    rem100 = number % 100;
    rem10 = number % 10;

    return word5 if rem100 >= 11 && rem100 <= 19
    return word5 if rem10 == 0
    return word1 if rem10 == 1
    return word2 if rem10 >= 2 && rem10 <= 4
    return word5 if rem10 >= 5 && rem10 <= 9
    return word5    
  end
  
  # f(х, "minute", "minutes")
  def pluralize_word_in_english(number, word1, word2)
    rem100 = number % 100;
    rem10 = number % 10;

    return word1 if rem10 == 1
    return word2
  end
  
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
