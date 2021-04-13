module ContactRecordHelper
  def display_author(contact_record)
    type = contact_record.contact_record_type
    return "#{I18n.t("hub.messages.automated")} " if type.to_s.include?("outgoing") && !contact_record.try(:author)

    contact_record.try(:author)
  end

  def message_heading(contact_record)
    case contact_record.contact_record_type
    when :incoming_text_message
      "#{I18n.t("hub.messages.from")} #{contact_record.from}"
    when :outgoing_text_message
      "#{I18n.t("hub.messages.to")} #{contact_record.to}"
    when :incoming_email
      "#{I18n.t("hub.messages.from")} #{contact_record.from}"
    when :outgoing_email
      "#{I18n.t("hub.messages.to")} #{contact_record.to}"
    when :incoming_portal_message
      I18n.t("hub.messages.portal_message")
    else
      contact_record.try(:heading)
    end
  end

  def twilio_deliverability_status(status)
    status ||= "sending"
    sent_statuses = %w[sent delivered]
    failed_statuses = %w[undelivered failed delivery_unknown]
    icon = "icons/waiting.svg"
    icon = "icons/exclamation.svg" if failed_statuses.include?(status)
    icon = "icons/check.svg" if sent_statuses.include?(status)
    image_tag(icon, alt: status, title: status, class: 'message__status')
  end

  def mailgun_deliverability_status(status)
    return unless status.present?

    sent_statuses = %w[delivered opened]
    failed_statuses = %w[permanent_fail]
    icon = "icons/waiting.svg"
    icon = "icons/exclamation.svg" if failed_statuses.include?(status)
    icon = "icons/check.svg" if sent_statuses.include?(status)
    image_tag(icon, alt: status, title: status, class: 'message__status')
  end

  def client_contact_preference(client, no_tags: false)
    contact_methods = ClientMessagingService.contact_methods(client)
    methods = contact_methods.keys&.map { |k| I18n.t("general.contact_methods.#{k}") }&.join("/")
    contacts = contact_methods.values&.join(" or ")
    message = I18n.t("portal.messages.new.contact_preference", contact_info: contacts, contact_method: methods)
    no_tags ? message : content_tag(:span, message)
  end
end