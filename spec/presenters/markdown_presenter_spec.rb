# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkdownPresenter do
  describe '.render' do
    it 'renders basic markdown' do
      expect(described_class.render('# Hello')).to include('<h1>Hello</h1>')
    end

    it 'returns an html_safe string' do
      expect(described_class.render('text')).to be_a(ActiveSupport::SafeBuffer)
    end
  end

  describe '#render' do
    subject(:presenter) { described_class.new }

    it 'renders paragraphs' do
      expect(presenter.render('Hello world')).to include('<p>Hello world</p>')
    end

    it 'renders emphasis' do
      expect(presenter.render('*italic*')).to include('<em>italic</em>')
      expect(presenter.render('**bold**')).to include('<strong>bold</strong>')
    end

    it 'converts bare URLs to links' do
      expect(presenter.render('https://example.com')).to include('<a href="https://example.com">https://example.com</a>')
    end

    it 'renders strikethrough' do
      expect(presenter.render('~~deleted~~')).to include('<del>deleted</del>')
    end

    it 'filters raw HTML' do
      expect(presenter.render('<script>alert(1)</script>')).not_to include('<script>')
    end

    context 'with fenced code blocks' do
      it 'highlights code with Pygments' do
        markdown = <<~MD
          ```ruby
          puts 'hello'
          ```
        MD
        result = presenter.render(markdown)
        expect(result).to include('highlight')
        expect(result).to include('puts')
      end

      it 'falls back to raw code when Pygments fails' do
        markdown = <<~MD
          ```unknown_lexer
          some code
          ```
        MD
        result = presenter.render(markdown)
        expect(result).to include('some code')
      end
    end
  end
end
