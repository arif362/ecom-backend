class Time
  def self.valid?(time)
    Time.parse(time)
    true
  rescue ArgumentError
    false
  end
end
