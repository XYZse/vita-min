class CreateZendeskIntakeTicketJob < ApplicationJob
  include ConsolidatedTraceHelper

  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)

    return unless intake.intake_ticket_id.blank?
    service = ZendeskIntakeService.new(intake)

    service.assign_requester &&
        service.assign_intake_ticket
  end

end
