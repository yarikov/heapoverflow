# frozen_string_literal: true

class MarkdownPresenter
  MARKDOWN_OPTIONS = {
    autolink: true,
    no_intra_emphasis: true,
    disable_indented_code_blocks: true,
    fenced_code_blocks: true,
    lax_html_blocks: true,
    strikethrough: true,
    superscript: true
  }.freeze

  class HTMLRenderer < Redcarpet::Render::HTML
    def block_code(code, language)
      Pygments.highlight(code, lexer: language)
    rescue StandardError
      code
    end
  end

  def self.render(content)
    new.render(content)
  end

  def render(content)
    renderer = HTMLRenderer.new(hard_wrap: true, filter_html: true)
    # Redcarpet filters HTML; output is safe to render
    # rubocop:disable Rails/OutputSafety
    Redcarpet::Markdown.new(renderer, MARKDOWN_OPTIONS).render(content).html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
