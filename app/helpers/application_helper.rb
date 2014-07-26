module ApplicationHelper
  def render_tumblr_post(post)
    if post['type'] == 'text'
      render partial:'post_text', locals:{post:post}
    elsif post['type'] == 'photo'
      render partial:'post_photo', locals:{post:post}
    elsif post['type'] == 'link'
      render partial:'post_link', locals:{post:post}
    elsif post['type'] == 'audio'
      render partial:'post_audio', locals:{post:post}
    elsif post['type'] == 'video'
      render partial:'post_video', locals:{post:post}
    else
      "Unknown type #{post['type']}"
    end
  end

  DEFAULT_TAGS = %w(fanart fanfic fanvideo fanmusic fantography article theory radiopsi)
  DEFAULT_TAGS_TEXT = "'#{DEFAULT_TAGS.join("','")}'".freeze
  def default_tags
    DEFAULT_TAGS_TEXT
  end
end
