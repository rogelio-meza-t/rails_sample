module DateTimeHelper
  def friendly_time_format(time)
    time.strftime("%k:%M").lstrip
  end

  def friendly_date_format(date)
    I18n.l(date)
  end

  def interchange_date_format(date)
    date.iso8601
  end
end
