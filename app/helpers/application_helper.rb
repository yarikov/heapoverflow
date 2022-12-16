# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def avatar_path(user, variant)
    if user.avatar.attached?
      rails_representation_path(user.avatar.variant(variant))
    else
      asset_path("#{variant}_avatar.png")
    end
  end

  def bootstrap_class_for(flash_type)
    { success: 'alert-success',
      error: 'alert-danger',
      alert: 'alert-warning',
      notice: 'alert-info' }[flash_type.to_sym] || flash_type.to_s
  end

  def active(options = {})
    options.each do |option|
      return 'active' if controller_name == option.first.to_s && action_name.in?(option.last)
    end
    ''
  end

  def shallow_path(*args)
    args.last.persisted? ? args.last : args
  end

  class HTMLwithPygments < Redcarpet::Render::HTML
    def block_code(code, language)
      Pygments.highlight(code, lexer: language)
    rescue StandardError
      code
    end
  end

  def markdown(content)
    renderer = HTMLwithPygments.new(hard_wrap: true, filter_html: true)
    options = {
      autolink: true,
      no_intra_emphasis: true,
      disable_indented_code_blocks: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true
    }
    Redcarpet::Markdown.new(renderer, options).render(content).html_safe
  end
end
