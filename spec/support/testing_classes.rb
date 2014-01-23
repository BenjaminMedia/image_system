class Response

  attr_accessor :status

  def initialize(**args)
    self.status = args[:status]
  end

end
