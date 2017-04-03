# frozen_string_literal: true

require 'spec_helper'

describe ServiceObjects do
  it 'has a version number' do
    expect(ServiceObjects::VERSION).not_to be nil
  end
end
