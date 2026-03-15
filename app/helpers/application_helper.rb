module ApplicationHelper
  # Returns the correct form model for nested (device context) or standalone interventions.
  def intervention_form_model(intervention, device)
    device ? [ device, intervention ] : intervention
  end
end
