class Line::SendOnLineService < Base::SendOnChannelService
  private

  def channel_class
    Channel::Line
  end

  def perform_reply
    byebug
    payload = if message.attachment?
                build_attachment_payload
              else
                [{ type: 'text', text: message.content }]
              end

    response = channel.client.push_message(message.conversation.contact_inbox.source_id, payload)
    return if response.blank?

    parsed_json = JSON.parse(response.body)

    if response.code == '200'
      # If the request is successful, update the message status to delivered
      message.update!(status: :delivered)
    else
      # If the request is not successful, update the message status to failed and save the external error
      message.update!(status: :failed, external_error: external_error(parsed_json))
    end
  end

  def build_attachment_payload
    case message.attachment_type
    when 'image'
      [{ type: 'image', originalContentUrl: message.attachment_url, previewImageUrl: message.attachment_url }]
    # Add more cases for other types of attachments like 'video', 'audio', etc.
    else
      [{ type: 'text', text: "Unsupported attachment type: #{message.attachment_type}" }]
    end
  end

  # https://developers.line.biz/en/reference/messaging-api/#error-responses
  def external_error(error)
    # Message containing information about the error. See https://developers.line.biz/en/reference/messaging-api/#error-messages
    message = error['message']
    # An array of error details. If the array is empty, this property will not be included in the response.
    details = error['details']

    return message if details.blank?

    detail_messages = details.map { |detail| "#{detail['property']}: #{detail['message']}" }
    [message, detail_messages].join(', ')
  end
end
