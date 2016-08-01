module Web::TasksHelper
  def show_attachment
    @task.attachment.content_type.match(/image/i) ? image_tag(@task.attachment_url) : link_to(@task.attachment.model[:attachment], @task.attachment_url)
  end
end
