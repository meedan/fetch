class Error
  def self.log(exception, opts={}, should_raise=false)
    puts [exception, opts]
    raise exception if should_raise
    nil
  end
end
