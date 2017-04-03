# frozen_string_literal: true

require 'spec_helper'

describe ServiceObjects::Base do
  subject { dummy_service.(call_params) }

  let(:dummy_service) { Class.new(described_class) }
  let(:call_params) { {} }

  before do
    dummy_service.class_exec do
      def process
        'Great news!'
      end
    end
  end

  it { expect(subject).to be_a(dummy_service) }
  it { expect(subject.result).to eq('Great news!') }
  it { expect(subject.call_params).to be_empty }
  it { expect(subject.success?).to be(true) }
  it { expect(subject.error?).to be(false) }
  it { expect(subject.errors).to be_empty }

  it 'delegate to result on method missing' do
    expect(subject.upcase).to eq('GREAT NEWS!')
  end

  context 'when service call requires arguments' do
    before do
      dummy_service.class_exec do
        attr_caller :message
      end
    end

    it { expect { subject }.to raise_error('missings keywords: message') }

    context 'when passed correct agruments' do
      let(:call_params) { { message: 'ok' } }

      it { expect(subject.success?).to eq(true) }
      it { expect(subject.call_params).to eq(call_params) }
      it { expect(subject.message).to eq('ok') }
    end

    context 'if service arguments have default values' do
      before do
        dummy_service.class_exec do
          attr_caller message: 'default'
        end
      end

      it { expect(subject.success?).to eq(true) }
      it { expect(subject.call_params).to be_empty }
      it { expect(subject.message).to eq('default') }
    end

    context 'inherited services' do
      subject { dummy_service_children.(call_params) }

      let(:dummy_service_children) { Class.new(dummy_service) }

      before do
        dummy_service_children.class_exec do
          attr_caller(
            message: 'volume of sphere',
            r: 1,
            func: ->(obj) { (3.14 * 4 / 3 * obj.r**3).round(2) }
          )

          def process
            func.(self)
          end
        end
      end

      it { expect(subject.result).to eq(4.19) }

      context 'when passing different values' do
        let(:call_params) { { r: 3 } }

        it { expect(subject.result).to eq(113.04) }
      end
    end
  end

  context 'if service arguments have proc as default values' do
    before do
      dummy_service.class_exec do
        attr_caller square: ->(val) { val * val }

        def process
          square.(square.(3))
        end
      end
    end

    it { expect(subject.square).to be_a(Proc) }
    it { expect(subject.result).to eq(81) }
  end

  context "when process don't implemented" do
    subject { Class.new(described_class).(call_params) }

    it { expect(subject.result).not_to be }
    it { expect(subject.error?).to be(true) }
    it { expect(subject.errors).to eq(['#process must be implemented']) }
  end
end
