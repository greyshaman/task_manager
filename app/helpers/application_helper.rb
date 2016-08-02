module ApplicationHelper
  BOOTSTRAP_FLASH_CLASSES = {
    success: 'alert-success',
    error: 'alert-error',
    alert: 'alert-warning',
    notice: 'alert-info'
  }
  def bootstrap_class_for flash_type
    BOOTSTRAP_FLASH_CLASSES[flash_type] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type.to_sym)} alert-dismissible fade in", role: "alert") do
              concat content_tag(:button, 'x', class: "close", data: {dismiss: 'alert'})
              concat message
            end)
    end
    nil
  end
end
