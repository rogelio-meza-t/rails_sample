
## Shorthand for setting attributes.

def time(hour, minute = 0)
  Time.new(2010, 10, 10, hour, minute)
end

def duration(hour, minutes = 0)
  BigDecimal.new("#{hour}.#{minutes}")
end
