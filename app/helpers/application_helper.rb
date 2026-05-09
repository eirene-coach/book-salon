module ApplicationHelper
  def embed_video(url)
    return '' if url.blank?

    if url.include?('youtube.com') || url.include?('youtu.be')
      vid_id = url.match(/(?:v=|youtu\.be\/)([A-Za-z0-9_-]{6,16})/)&.[](1)
      return '<p class="text-red-500">영상을 불러올 수 없습니다.</p>'.html_safe unless vid_id
      content_tag(:iframe, '',
        class: 'absolute top-0 left-0 w-full h-full rounded-xl',
        src: "https://www.youtube.com/embed/#{vid_id}",
        frameborder: '0', allowfullscreen: true)
    elsif url.include?('vimeo.com')
      vid_id = url.match(/vimeo\.com\/(\d+)/)&.[](1)
      return '<p class="text-red-500">영상을 불러올 수 없습니다.</p>'.html_safe unless vid_id
      content_tag(:iframe, '',
        class: 'absolute top-0 left-0 w-full h-full rounded-xl',
        src: "https://player.vimeo.com/video/#{vid_id}",
        frameborder: '0', allowfullscreen: true)
    else
      '<p class="text-red-500">영상을 불러올 수 없습니다.</p>'.html_safe
    end
  end
end
