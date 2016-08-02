module Web::TasksHelper
  def show_attachment
    if @task.attachment.try(:content_type).try(:match, /image/i)
      image_tag(@task.attachment_url)
    else
      link_to(@task.attachment.model[:attachment], @task.attachment_url, target: '_blank')
    end
  rescue
    ""
  end
end
