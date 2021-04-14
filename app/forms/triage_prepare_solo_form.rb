class TriagePrepareSoloForm < QuestionsForm
  set_attributes_for :triage, :will_prepare

  def initialize(form_params = {})
    super(nil, form_params)
  end

  def will_prepare?
    will_prepare == "yes"
  end
end