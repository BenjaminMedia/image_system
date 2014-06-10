module ImageSystem
  module Exceptions
    class ImageSystemError < StandardError
    end

    class AlreadyExistsException < ImageSystemError
    end

    class CdnResponseException < ImageSystemError
    end

    class CdnUnknownException < ImageSystemError
    end

    class NotFoundException < ImageSystemError
    end

    class WrongCroppingFormatException < ImageSystemError
    end
  end
end
