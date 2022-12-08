# frozen_string_literal: true

module ApplicationHelper
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

  def flash_messages(_opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} alert-dismissible",
                                        role: 'alert') do
               concat(content_tag(:button, class: 'close', data: { dismiss: 'alert' }) do
                 concat content_tag(:span, '&times;'.html_safe, 'aria-hidden' => true)
                 concat content_tag(:span, 'Close', class: 'sr-only')
               end)
               concat message
             end)
    end
    nil
  end

  def active(options = {})
    options.each do |option|
      return 'active' if controller_name == option.first.to_s && action_name.in?(option.last)
    end
    ''
  end

  def vote_up_link_to(path, obj)
    vote_class = user_signed_in? && current_user.vote_up?(obj) ? 'vote-up-on' : 'vote-up-off'
    link_to '', path, data: { turbo_method: :post }, class: vote_class.to_s
  end

  def vote_down_link_to(path, obj)
    vote_class = user_signed_in? && current_user.vote_down?(obj) ? 'vote-down-on' : 'vote-down-off'
    link_to '', path, data: { turbo_method: :post }, class: vote_class.to_s
  end

  def best_link_to(path, obj)
    best_class = obj.best ? 'best' : 'not_best'
    link_to '', path, data: { turbo_method: :patch }, class: "glyphicon glyphicon-ok #{best_class}"
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
