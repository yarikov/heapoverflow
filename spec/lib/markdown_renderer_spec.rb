# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkdownRenderer do
  describe '.call' do
    it 'renders basic markdown' do
      expect(described_class.call('# Hello')).to include('<h1>Hello</h1>')
    end

    it 'returns an html_safe string' do
      expect(described_class.call('text')).to be_a(ActiveSupport::SafeBuffer)
    end
  end

  describe '#call' do
    subject(:renderer) { described_class.new }

    it 'renders paragraphs' do
      expect(renderer.call('Hello world')).to include('<p>Hello world</p>')
    end

    it 'renders emphasis' do
      expect(renderer.call('*italic*')).to include('<em>italic</em>')
      expect(renderer.call('**bold**')).to include('<strong>bold</strong>')
    end

    it 'converts bare URLs to links' do
      expect(renderer.call('https://example.com')).to include('<a href="https://example.com">https://example.com</a>')
    end

    it 'renders strikethrough' do
      expect(renderer.call('~~deleted~~')).to include('<del>deleted</del>')
    end

    it 'filters raw HTML' do
      expect(renderer.call('<script>alert(1)</script>')).not_to include('<script>')
    end

    context 'with fenced code blocks' do
      it 'highlights code with Pygments' do
        markdown = <<~MD
          ```ruby
          puts 'hello'
          ```
        MD
        result = renderer.call(markdown)
        expect(result).to include('highlight')
        expect(result).to include('puts')
      end

      it 'escapes code when Pygments fails' do
        markdown = <<~MD
          ```unknown_lexer
          <script>alert('xss')</script>
          ```
        MD
        result = renderer.call(markdown)
        expect(result).to include('&lt;script&gt;')
        expect(result).not_to include('<script>')
      end
    end
  end
end
