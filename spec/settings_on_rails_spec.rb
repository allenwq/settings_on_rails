require 'spec_helper'
require 'support/models'
require 'settings_on_rails'

RSpec.describe SettingsOnRails do
  before(:each) { clear_database }

  describe 'column type validations' do
    context 'with exiting column of type text' do
      before { Blog.class_eval { has_settings_on :settings } }
      let(:blog) { Blog.new }

      it 'responds to the method' do
        expect(blog).to respond_to(:settings)
      end

      it 'is able to call the method' do
        expect{blog.settings}.not_to raise_error
      end
    end

    context 'with non exist column' do
      before { Blog.class_eval { has_settings_on :any_column } }
      let(:blog) { Blog.new }

      it 'raises an error' do
        expect{blog.settings}.to raise_error(SettingsOnRails::ColumnNotExistError)
      end
    end

    context 'with existing column of other types' do
      before { Blog.class_eval { has_settings_on :name } }
      let(:blog) { Blog.new }

      it 'raises an error' do
        expect{blog.settings}.to raise_error(SettingsOnRails::InvalidColumnTypeError)
      end
    end
  end

  describe '#settings' do
    before { Blog.class_eval { has_settings_on :settings } }
    let(:blog) { Blog.new }

    describe 'key validations' do
      let(:valid_keys) { %w(key KEY key_ key_1) }
      let(:invalid_keys) { %w(_key 1key) }

      context 'with valid keys' do
        it 'does not raise any errors' do
          valid_keys.each do |key|
            expect{ blog.settings.send(key + '=', 'value') }.not_to raise_error
          end
        end
      end

      context 'with invalid keys' do
        it 'does not raise any errors' do
          invalid_keys.each do |key|
            expect{ blog.settings.send(key + '=', 'value') }.to raise_error
          end
        end
      end
    end

    describe 'get/set attributes' do
      let(:attributes) { [true, 'text', 100] }

      context 'set and get attributes' do
        before do
          attributes.each do |attr|
            key = 'attr_' + attr.to_s
            blog.settings.send(key + '=', attr)
          end
        end

        it 'returns the value as set' do
          attributes.each do |attr|
            key = 'attr_' + attr.to_s
            expect(blog.settings.send(key)).to eq attr
          end
        end

        context 'after save' do
          before { blog.save }

          it 'returns the value as set' do
            attributes.each do |attr|
              key = 'attr_' + attr.to_s
              expect(blog.reload.settings.send(key)).to eq attr
            end
          end
        end
      end
    end

    describe 'multiple/nested keys' do
      let(:text) { 'SETTINGS ON RAILS' }
      context 'set value with multiple keys' do
        before { blog.settings(:key1, :key2, :key3).value = text }

        it 'returns the correct value' do
          expect(blog.settings(:key1, :key2, :key3).value).to eq text
          expect(blog.settings(:key1).settings(:key2).settings(:key3).value).to eq text
          expect(blog.settings(:key1, :key2).settings(:key3).value).to eq text
        end
      end

      context 'set value with nested keys' do
        before { blog.settings(:key1).settings(:key2).settings(:key3).value = text }

        it 'returns the correct value' do
          expect(blog.settings(:key1, :key2, :key3).value).to eq text
          expect(blog.settings(:key1).settings(:key2).settings(:key3).value).to eq text
          expect(blog.settings(:key1, :key2).settings(:key3).value).to eq text
        end
      end
    end
  end
end
