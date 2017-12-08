require 'spec_helper'

describe GrapeApiary::Route do
  include_context 'configuration'

  let(:routes) { GrapeApiary::Blueprint.new(SampleApi).routes }

  subject { routes.first }

  describe "#route_name" do
    context "when the route is GET /widgets" do
      it "is 'widgets'" do
        expect(subject.route_name).to eq('widgets')
      end
    end
  end

  describe "#path_without_format" do
    context "when the route is GET /widgets" do
      it "is '/widgets" do
        expect(subject.path_without_format).to eq('/widgets')
      end
    end
  end

  describe "#route_type" do
    context "when the route is GET /widgets" do
      it "is 'collection" do
        expect(subject.route_type).to eq('collection')
      end
    end

    context "when the route is GET /widgets/:id" do
      subject(:individual_widget) { routes.second }

      it "is 'single'" do
        expect(individual_widget.route_type).to eq('single')
      end
    end
  end

  describe '#list?' do
    context 'when the route is a collection route' do
      it 'is true' do
        expect(subject.list?).to eq(true)
      end
    end

    context 'when the route is not a collection route' do
      subject(:individual_widget) { routes.second }

      it 'is false' do
        expect(subject.list?).to eq(false)
      end
    end
  end
end
