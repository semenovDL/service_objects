# frozen_string_literal: true

module ServiceObjects
  # TODO
  module KeywordArguments
    def self.included(base) # rubocop:disable Metrics/MethodLength
      base.extend ClassMethods
      base.include InstanceMethods
      base.class_exec do
        %i(_strong_fields _fields_with_default_values).each do |class_attribute|
          define_singleton_method("#{class_attribute}=") do |val|
            singleton_class.class_eval do
              define_method(class_attribute) do
                val
              end
            end
            val
          end

          define_method(class_attribute) do
            self.class.public_send(class_attribute)
          end
        end
      end
    end

    # TODO
    module ClassMethods
      def attr_caller(*keywords_array, **keywords_hash)
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

      def _strong_fields
        @_strong_fields ||= []
      end

      def _fields_with_default_values
        @_fields_with_default_values ||= {}
      end
    end

    # TODO
    module InstanceMethods
      attr_reader :call_params

      private

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
          call_params.key?(field) || instance_variable_set(:"@#{field}", val)
        end
      end
    end
  end
end
