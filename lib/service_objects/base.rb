# frozen_string_literal: true

module ServiceObjects
  # TODO
  class Base
    attr_reader :result, :call_params

    def self.call(**params, &_block)
      new(**params).tap do |object|
        result = object.process
        if object.success?
          object.instance_variable_set(:@result, result)
          yield result if block_given?
        end
      end
    end

    def self.attr_caller(*keywords_array, **keywords_hash)
      keywords_array |= keywords_hash.keys
      return if keywords_array.empty?
      new_fields = keywords_array - _strong_fields
      self._strong_fields |= keywords_array
      self._fields_with_default_values =
        _fields_with_default_values.merge(keywords_hash)
      new_fields.each do |field|
        attr_reader field
      end
    end

    def process
      errors << '#process must be implemented'
    end

    def errors
      @errors ||= []
    end

    def success?
      errors.empty?
    end

    def error?
      errors.any?
    end

    private

    def self._class_attribute(*attrs) # rubocop:disable Metrics/MethodLength
      attrs.each do |name|
        define_singleton_method("#{name}=") do |val|
          singleton_class.class_eval do
            define_method(name) do
              val
            end
          end
          val
        end

        define_method(name) do
          self.class.public_send(name)
        end
      end
    end
    private_class_method :_class_attribute

    _class_attribute :_strong_fields, :_fields_with_default_values
    self._strong_fields = []
    self._fields_with_default_values = {}

    def initialize(**call_params)
      @call_params = call_params
      _check_params
      _initialize_params
      _initialize_defaults
    end

    def _check_params
      missings = _strong_fields.reject do |field|
        call_params.key?(field) || _fields_with_default_values.key?(field)
      end
      missings.empty? ||
        raise(ArgumentError, "missings keywords: #{missings.join(', ')}")
    end

    def _initialize_params
      call_params.each do |field, val|
        instance_variable_set(:"@#{field}", val)
      end
    end

    def _initialize_defaults
      _fields_with_default_values.each do |field, val|
        instance_variable_set(:"@#{field}", val) unless call_params.key?(field)
      end
    end

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
