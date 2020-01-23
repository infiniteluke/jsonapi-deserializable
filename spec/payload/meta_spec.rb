require 'spec_helper'

describe JSONAPI::Deserializable::Payload, '.meta' do
  it 'creates corresponding field' do
    payload = { 'meta' => { 'count' => 100 } }
    # Use a meta block that provides some default meta (author)
    klass = Class.new(JSONAPI::Deserializable::Payload) do
      meta { |t| t.merge({ 'author' => 'Luke Herrington' }) }
    end

    actual = klass.call(payload)

    expected = { meta: { 'count' => 100, 'author' => 'Luke Herrington' } }
    expect(actual.meta).to eq(expected)
  end

  it 'defaults to creating a meta field' do
    payload = { 'meta' => { 'count' => 100 } }
    klass = Class.new(JSONAPI::Deserializable::Payload) do
      meta
    end

    actual = klass.call(payload)

    expected = { meta: { 'count' => 100 } }
    expect(actual.meta).to eq(expected)
  end
end
