# frozen_string_literal: true

class MarkdownRenderer
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
      "<pre><code>#{ERB::Util.html_escape(code)}</code></pre>"
    end
  end

  def self.call(...) = new.call(...)

  def call(content)
    renderer = HTMLRenderer.new(hard_wrap: true, filter_html: true)
    html = Redcarpet::Markdown.new(renderer, MARKDOWN_OPTIONS).render(content)

    # Redcarpet filters source HTML, and HTMLRenderer escapes its fallback output.
    # rubocop:disable Rails/OutputSafety
    html.html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
