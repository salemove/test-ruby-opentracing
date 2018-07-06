# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OpenTracingTestTracer::ScopeManager::ScopeIdentifier do
  describe '.generate' do
    it 'generates an identifier' do
      id = described_class.generate
      expect(id).to be_a(Symbol)
      expect(id).to match(/opentracing_[A-Z]{8}/)
    end
  end
end
