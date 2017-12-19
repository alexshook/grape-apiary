require 'spec_helper'

describe GrapeApiary::SampleGenerator do
  include_context 'configuration'

  before do
    GrapeApiary.config do |config|
      config.host               = host
      config.name               = name
      config.description        = description
      config.include_root       = false
    end
  end

  let(:fake_formatter)  { Class.new }
  let(:entity)          { V20170505::Entities::Widget }

  let(:stub_jsonapi) do
    stub_const('Grape::Jsonapi::Formatter', fake_formatter)
    expect(Grape::Jsonapi::Document).to receive(:top).and_return(entity)
    expect(entity).to receive(:represent)
    expect(Widget).to receive(:last)
    expect(Grape::Jsonapi::Formatter).to receive(:call).and_return({})
  end

  let(:blueprint) { GrapeApiary::Blueprint.new(SampleApi) }
  let(:resource)  { blueprint.resources.first }

  subject { GrapeApiary::SampleGenerator.new(resource) }

  context '#request' do
    before { stub_jsonapi }

    it 'creates a sample request in JSON form' do
      expect { JSON.parse(subject.request) }.to_not raise_error
    end
  end

  context '#response' do
    before { stub_jsonapi }

    it 'creates a sample response in JSON form' do
      expect { JSON.parse(subject.response) }.to_not raise_error
    end

    it 'includes a sample id' do
      expect(JSON.parse(subject.response)['id']).to_not be(nil)
    end
  end

  context '#sample' do
    context 'when the JSON API entity exists' do
      it 'is the entity hash' do
        stub_const('Grape::Jsonapi::Formatter', fake_formatter)

        expect(Grape::Jsonapi::Document).to receive(:top).and_return(entity)
        expect(entity).to receive(:represent)
        expect(Widget).to receive(:last)
        expect(Grape::Jsonapi::Formatter).to receive(:call).and_return({})
        expect(JSON).to receive(:parse).with({})

        subject.sample
      end
    end

    context 'when the JSON API entity does not exist' do
      it 'is the legacy sample hash' do
        expect(subject.sample).to eq(
          'description' => 'the best widget ever made',
          'name' => 'super widget'
        )
      end
    end
  end
end
