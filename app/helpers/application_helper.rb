require 'redcarpet'
module ApplicationHelper
  def markdown(text)
    if text == nil
      return
    end
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true, escape_html: false)
    options = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true
    }
    Redcarpet::Markdown.new(renderer, options).render(text).html_safe
  end

  def markdown_no_p(text)
    ret = markdown(text)
    ActiveSupport::SafeBuffer.new(Regexp.new('^<p>(.*)<\/p>$').match(ret)[1]) rescue ret
  end

  def markdown_no_html(text)
    if text == nil
      return
    end
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true, escape_html: true)
    options = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true
    }
    Redcarpet::Markdown.new(renderer, options).render(text).html_safe
  end

  def destroy_glyph
    return raw '<span class="glyphicon glyphicon-trash"></span>'
  end

  def edit_glyph
    return raw '<span class="fui-new"></span>'
  end

  def pin_glyph
    return raw '<span class="glyphicon glyphicon-pushpin"></span>'
  end

  def rejudge_glyph
    return raw '<span class="glyphicon glyphicon-repeat"></span>'
  end

  def verdict_text(x)
    class_map = {
      "AC" => "text-success",
      "WA" => "text-danger",
      "TLE" => "text-info",
      "MLE" => "text-mle",
      "OLE" => "text-ole",
      "RE" => "text-warning",
      "SIG" => "text-sig",
      "queued" => "text-muted",
    }
    if class_map[x]
      return raw '<span class="' + class_map[x] + '">' + x + '</span>'
    else
      return x
    end
  end

  def help_icon(x)
    raw '<a href="' + x + '" style="color: inherit;" class="glyphicon glyphicon-question-sign"></a>'
  end

  def help_collapse_toggle(x, target)
    raw x + ' <a class="glyphicon glyphicon-question-sign" style="color: inherit;" data-toggle="collapse" href="#' + target + '" role="button" aria-expanded="false" aria-controls="collapseExample"></a>'
  end

  def score_str(x)
    number_with_precision(x, strip_insignificant_zeros: true, precision: 6)
  end

  def visible_state_desc_map
    {
      "public" => "public",
      "contest" => "only visible during contest",
      "invisible" => "invisible",
    }
  end

  def page_title(title)
    title.empty? ? Rails.application.config.site_name : title
  end

  def set_page_title(title, site_name = nil)
    site_name ||= Rails.application.config.site_name
    if params[:page]
      @page_title = "#{title} - Page #{params[:page]}"
    else
      @page_title = title
    end
    @page_title = "#{@page_title} | #{site_name}"
    content_for :title, @page_title
  end

  def to_us(x)
    return x.to_i * 1000000 + x.usec
  end
end
