# frozen_string_literal: true

module ServiceObjects
  # TODO
  module Errors
    def errors
      @errors ||= []
    end

    def success?
      errors.empty?
    end

    def error?
      errors.any?
    end
  end
end
