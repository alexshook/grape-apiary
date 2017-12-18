module GrapeApiary
  class Route < SimpleDelegator
    # would like to rely on SimpleDelegator but Grape::Route uses
    # method_missing for these methods :'(
    delegate :namespace, :path, :request_method, to: '__getobj__'

    def params
      @params ||= begin
        __getobj__.params.stringify_keys.sort.map do |param|
          Parameter.new(self, *param)
        end
      end
    end

    def route_name
      namespace.split('/').last ||
        path.match('\/(\w*?)[\.\/\(]').captures.first
    end

    def description
      "#{__getobj__.description} [#{request_method.upcase}]"
    end

    def api_blueprintified_path
      path_pieces = path_without_format.split("/")
      path_pieces.map do |piece|
        piece.match(/:/) ? api_blueprintify_ids(piece) : piece
      end.join("/")
    end

    def path_without_format
      path.gsub(/\((.*?)\)/, '')
    end

    def route_model
      namespace.split('/').last.singularize
    end

    def route_type
      list? ? 'collection' : 'single'
    end

    def request_description
      "+ Request #{'(application/vnd.api+json)' if request_body?}"
    end

    def response_description
      code = request_method == 'POST' ? 201 : 200

      "+ Response #{code} (application/vnd.api+json)"
    end

    def list?
      return verify_with_legacy_list_method unless action_name.presence

      # TODO this doesn't handle create when passed an array
      action_name == 'list'
    end

    private

    def api_blueprintify_ids(path_piece)
      path_piece.split(//).drop(1).unshift("{").push("}").join
    end

    def verify_with_legacy_list_method
      %w(GET POST).include?(request_method) && !path.include?(':id')
    end

    def action_name
      options.dig(
        :params,
        route_name.parameterize,
        :documentation,
        :action
      )
    end

    def request_body?
      !%w(GET DELETE).include?(request_method)
    end
  end
end
