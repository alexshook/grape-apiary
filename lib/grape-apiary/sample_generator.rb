module GrapeApiary
  class SampleGenerator
    attr_reader :resource, :root

    delegate :unique_params, :name, to: :resource

    def initialize(resource)
      @resource = resource
      @root     = resource.key.singularize
    end

    def sample(id = false)
      begin
        model = name.sub(":", "").capitalize.constantize
        entity = Grape::Jsonapi::Document.top("V20170505::Entities::#{model}".constantize)
        entity.represent(data: model.last)
      rescue
        array = resource.unique_params.map do |param|
          next if param.name == root

          [param.name, param.example]
        end

        hash = Hash[array.compact]

        hash = hash.reverse_merge(id: Config.generate_id) if id
        hash = { root => hash } if Config.include_root

        hash
      end
    end

    def request
      hash = sample

      return unless hash.present?

      # format json spaces for blueprint markdown
      JSON
        .pretty_generate(hash)
        .gsub('{', (' ' * 14) + '{')
        .gsub('}', (' ' * 14) + '}')
        .gsub(/\ {2}\"/, (' ' * 16) + '"')
    end

    def response(list = false)
      return unless (hash = sample(true)).present?

      pretty_response_for(list ? [hash] : hash)
    end

    private

    # rubocop:disable Metrics/AbcSize
    def pretty_response_for(hash)
      JSON
        .pretty_generate(hash)
        .gsub('[', (' ' * 12) + '[')
        .gsub(']', (' ' * 12) + ']')
        .gsub('{', (' ' * 14) + '{')
        .gsub('}', (' ' * 14) + '}')
        .gsub(/\ {2}\"/, (' ' * 16) + '"')
    end
    # rubocop:enable Metrics/AbcSize
  end
end
