# frozen_string_literal: true

module ServiceObjects
  # TODO
  class Base
    include ServiceObjects::KeywordArguments
    include ServiceObjects::Delegation
    include ServiceObjects::Errors

    def self.call(**params, &_block)
      new(**params).tap do |object|
        result = object.process
        if object.success?
          object.instance_variable_set(:@result, result)
          yield result if block_given?
        end
      end
    end

    def process
      errors << '#process must be implemented'
    end
  end
end
