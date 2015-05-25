require 'spec_helper'
require 'support/models'
require 'settings_on_rails'

RSpec.describe 'Default settings' do
  before(:each) { clear_database }

  describe '.has_settings_on' do
    it 'responds to a block' do
      expect do
        Blog.class_eval do
          has_settings_on(:settings).has_settings(:homepage) do |s|
            s.key :background, defaults: { color: 'red', image: 'bg.png' }
            s.attr :text_size, default: 50
          end
        end
      end.not_to raise_error
    end

    describe 'arguments validation' do
      context 'when column is not symbol' do
        it 'raises an error' do
          expect{ Blog.class_eval { has_settings_on 'settings' } }.not_to raise_error
        end
      end

      context 'when key is string' do
        it 'raises an error' do
          expect do
            Blog.class_eval do
              has_settings_on :settings do |s|
                s.key 'theme', defaults: { title: 'bootstrap' }
              end
            end
          end.not_to raise_error
        end
      end

      context 'when attr is not symbol' do
        it 'raises an error' do
          expect do
            Blog.class_eval do
              has_settings_on :settings do |s|
                s.attr Object.new, default: 'bootstrap'
              end
            end
          end.to raise_error(ArgumentError)
        end

        it 'does not raise any errors for string' do
          expect do
            Blog.class_eval do
              has_settings_on :settings do |s|
                s.attr 'key', default: 'bootstrap'
              end
            end
          end.not_to raise_error
        end
      end

      context 'when default value key not specified' do
        it 'raises an error' do
          expect do
            Blog.class_eval do
              has_settings_on :settings do |s|
                s.attr :theme, random_key: 'bootstrap'
              end
            end
          end.to raise_error(ArgumentError)

          expect do
            Blog.class_eval do
              has_settings_on :settings do |s|
                s.key :theme, random_key: { name: 'bootstrap'}
              end
            end
          end.to raise_error(ArgumentError)
        end
      end
    end

    describe 'default values' do
      before do
        Blog.class_eval do
          has_settings_on(:settings) do |s|
            s.key :background, defaults: { color: 'red', image: 'bg.png' }
            s.attr :text_size, default: 50
          end
        end
      end
      subject { Blog.new }

      it 'returns the default value' do
        expect(Blog.new.settings(:background).color).to eq 'red'
        expect(Blog.new.settings.text_size).to eq 50
      end
    end
  end

  describe '.has_settings' do
    before { Blog.class_eval { has_settings_on :settings } }

    it 'responds to the method' do
      expect do
        Blog.class_eval do
          has_settings(:theme).has_settings(:homepage) do |s|
            s.key :background, defaults: { color: 'red', image: 'bg.png' }
            s.attr :text_size, default: 50
          end
        end
      end.not_to raise_error
    end

    describe 'arguments validation' do
      context 'when arguments are not symbol' do
        it 'raises an error' do
          expect { Blog.class_eval { has_settings('theme') } }.not_to raise_error
          expect { Blog.class_eval { has_settings(:posts, 'theme') } }.not_to raise_error
          expect { Blog.class_eval { has_settings(:posts).has_settings('theme') } }.not_to raise_error
        end
      end

      context 'when key is string' do
        it 'does not raise any errors' do
          expect do
            Blog.class_eval do
              has_settings do |s|
                s.key 'theme', defaults: { title: 'bootstrap' }
              end
            end
          end.not_to raise_error
        end
      end

      context 'when attr is string' do
        it 'does not raise any errors' do
          expect do
            Blog.class_eval do
              has_settings do |s|
                s.attr 'theme', default: 'bootstrap'
              end
            end
          end.not_to raise_error
        end
      end

      context 'when default value key not specified' do
        it 'raises an error' do
          expect do
            Blog.class_eval do
              has_settings do |s|
                s.attr :theme, random_key: 'bootstrap'
              end
            end
          end.to raise_error(ArgumentError)

          expect do
            Blog.class_eval do
              has_settings do |s|
                s.key :theme, random_key: { name: 'bootstrap'}
              end
            end
          end.to raise_error(ArgumentError)
        end
      end
    end

    describe 'default values' do
      context 'nested keys' do
        before do
          Blog.class_eval do
            has_settings(:theme).has_settings(:homepage) do |s|
              s.key :background, defaults: { color: 'red', image: 'bg.png' }
              s.attr :text_size, default: 50
            end
          end
        end
        let(:blog) { Blog.new }

        it 'returns the default value' do
          expect(blog.settings(:theme).settings(:homepage).text_size).to eq 50
          expect(blog.settings(:theme).settings(:homepage).settings(:background).color).to eq 'red'
          expect(blog.settings(:theme, :homepage).text_size).to eq 50
          expect(blog.settings(:theme, :homepage, :background).color).to eq 'red'
        end
      end

      context 'multiple keys' do
        before do
          Blog.class_eval do
            has_settings(:theme, :homepage) do |s|
              s.key :background, defaults: { color: 'red', image: 'bg.png' }
              s.attr :text_size, default: 50
            end
          end
        end
        let(:blog) { Blog.new }

        it 'returns the default value' do
          expect(blog.settings(:theme).settings(:homepage).text_size).to eq 50
          expect(blog.settings(:theme).settings(:homepage).settings(:background).color).to eq 'red'
          expect(blog.settings(:theme, :homepage).text_size).to eq 50
          expect(blog.settings(:theme, :homepage, :background).color).to eq 'red'
        end
      end

      context 'no keys' do
        before do
          Blog.class_eval do
            has_settings do |s|
              s.key :background, defaults: { color: 'red', image: 'bg.png' }
              s.attr :text_size, default: 50
            end
          end
        end
        let(:blog) { Blog.new }

        it 'returns the default value' do
          expect(blog.settings.text_size).to eq 50
          expect(blog.settings(:background).color).to eq 'red'
        end
      end

      context 'with settings' do
        before do
          Blog.class_eval do
            has_settings(:theme).has_settings(:homepage, :body) do |s|
              s.key 'background', defaults: { color: 'red', image: 'bg.png' }
              s.attr :text_size, default: 50
            end
          end
        end
        let(:blog) { Blog.new }

        before do
          blog.settings(:theme).settings(:homepage).settings(:body).text_size = 100
          blog.settings(:theme).settings(:homepage).settings(:body, :background).color = 'blue'
        end

        it 'returns the actual value' do
          expect(blog.settings(:theme).settings(:homepage, :body).text_size).to eq 100
          expect(blog.settings(:theme).settings(:homepage, :body).settings(:background).color).to eq 'blue'
          expect(blog.settings(:theme, :homepage,:body).text_size).to eq 100
          expect(blog.settings(:theme, :homepage, :body, :background).color).to eq 'blue'
        end

        context 'after save' do
          before do
            blog.save
            blog.reload
          end

          it 'returns the actual value' do
            expect(blog.settings(:theme).settings(:homepage, :body).text_size).to eq 100
            expect(blog.settings(:theme).settings(:homepage, :body).settings(:background).color).to eq 'blue'
            expect(blog.settings(:theme, :homepage,:body).text_size).to eq 100
            expect(blog.settings(:theme, :homepage, :body, :background).color).to eq 'blue'
          end
        end
      end
    end
  end
end

