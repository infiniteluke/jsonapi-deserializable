require 'spec_helper'

describe JSONAPI::Deserializable::Payload, '.links' do
  it 'creates corresponding field' do
    payload = { 'links' => { 'related' => { 'href' => 'https://example.com/api/example/', 'meta' => { 'count' =>  10 } } } }
    klass = Class.new(JSONAPI::Deserializable::Payload) do
      links { |t| t.merge({ 'recommended' => 'https://example.com/api/example/1' }) }
    end

    actual = klass.call(payload)

    expected = { links: { 'recommended' => 'https://example.com/api/example/1', 'related' => { 'href' => 'https://example.com/api/example/', 'meta' => { 'count' =>  10 } } } }
    expect(actual.links).to eq(expected)
  end

  it 'defaults to creating a links field' do
    payload = { 'links' => { 'related' => { 'href' => 'https://example.com/api/example/', 'meta' => { 'count' =>  10 } } } }
    klass = Class.new(JSONAPI::Deserializable::Payload) do
      links
    end

    actual = klass.call(payload)

    expected = { links: { 'related' => { 'href' => 'https://example.com/api/example/', 'meta' => { 'count' =>  10 } } } }
    expect(actual.links).to eq(expected)
  end
end
