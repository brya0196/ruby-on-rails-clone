require 'json/ext'
module Http
  class Response
    attr_accessor :status, :headers, :content

    # @param type Symbol
    # @param content Hash|String
    # @return Http::Response
    def render(type, content)
      return json(content) if type == :json
      view(content)
    end
    
    # @param layout string
    # @return LayoutRenderer
    def layout(layout = "layout/application")
      Template::Renderer.new.layout(layout)
    end

    # @return Http::Response
    def not_found
      resolve_route(Routing::StatusCode::NOT_FOUND, "Not Found", {})
    end

    # @return Http::Response
    def internal_error
      resolve_route(Routing::StatusCode::INTERNAL_SERVER_ERROR, "Internal Server Error", {})
    end

    # static methods

    # @param name String
    # @return Http::Response
    def self.view(name = "#{self.name}.#{self.action}")
      Response.new.render(:view, name)
    end

    # @param json Hash
    # @return Http::Response
    def self.json(data = {})
      Response.new.render(:json, data, nil)
    end

    

    private

    # @param content string|render
    # @param headers Hash
    # @return Routing::BaseController
    def resolve_with_okay_status(content, headers)
      resolve_route(Routing::StatusCode::OK, content, headers)
    end
    
    # @param status Routing::StatusCode
    # @param content string|render
    # @param headers Hash
    # @return Routing::BaseController
    def resolve_route(status = Routing::StatusCode::OK, content = "", headers = {"Content-Type" => "text/html"})
      self.status = status
      self.headers = headers
      self.content = [content]
      self
    end

    # @param name string
    # @return Http::Response
    def view(name = "#{self.name}.#{self.action}")
      resolve_with_okay_status(render_view(name), {"Content-Type" => "text/html"})
    end

    # @param json [Hash, Hash]
    # @return Http::Response
    def json(data = {})
      resolve_with_okay_status(data.to_json, {"Content-Type" => "application/json"})  
    end

    # params name String
    # @return String
    def render_view(name)
      layout.render do
        Template::Renderer.new.partial(name)
      end
    end
  end
end