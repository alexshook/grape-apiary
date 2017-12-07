require 'spec_helper'

describe GrapeApiary::Route do
  include_context 'configuration'

  let(:routes) { GrapeApiary::Blueprint.new(SampleApi).routes }

  subject { routes.first }

  it 'adds a name helper to routes' do
    expect(subject.route_name).to eq('widgets')
  end

  it 'adds a path helper without format' do
    expect(subject.path_without_format).to eq('/widgets')
  end

  it 'adds a type helper' do
    expect(subject.route_type).to eq('collection')
  end

  describe '#list?' do
    context 'when the action is show' do
      before { expect(subject).to receive(:named).and_return('widgets#show') }

      it 'is true' do
        expect(subject.list?).to eq(true)
      end
    end

    context 'when the action is anything else' do
      before { expect(subject).to receive(:named).and_return(nil) }

      it 'is false' do
        expect(subject.list?).to eq(false)
      end
    end
  end
end
