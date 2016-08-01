module Web::TasksHelper
  def show_attachment
    @task.attachment.try(:content_type).try(:match, /image/i) ? image_tag(@task.attachment_url) : link_to(@task.attachment.model[:attachment], @task.attachment_url, target: '_blank')
  end
end
