class MainController < Routing::BaseController
  def index
    @test = "#{environment("APP_NAME")}"
    @arr = %w(one two three)
  end

  def create; end
end