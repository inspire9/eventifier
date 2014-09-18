module Eventifier::API::View
  private

  def render(template, locals = {})
    response.body = renderer.render template: template, locals: locals
  end

  def renderer
    ApplicationController.view_context_class.new(
      ApplicationController.view_paths
    )
  end
end
