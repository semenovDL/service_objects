# frozen_string_literal: true

module ServiceObjects
  # TODO
  module Delegation
    attr_reader :result

    def method_missing(method_name, *opts)
      if respond_to?(method_name)
        result.public_send(method_name, *opts)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      result&.respond_to?(method_name, include_private) || super
    end
  end
end
