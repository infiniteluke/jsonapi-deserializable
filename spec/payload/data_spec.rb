require 'spec_helper'

describe JSONAPI::Deserializable::Payload, '.data' do
  it 'creates corresponding field' do
    payload = { 'data' => [
      { 'type' => 'post', 'id' => 1, 'attributes' => { 'title' => 'Deserializing for dummies' } },
      { 'type' => 'post', 'id' => 2, 'attributes' => { 'title' => 'JSON:API Paints Your Bikeshed' } },
    ] }
    klass = Class.new(JSONAPI::Deserializable::Payload) do
      data { |t| t['attributes'] }
    end

    actual = klass.call(payload)
    expected = { data: [{ 'title' => 'Deserializing for dummies' }, { 'title' => 'JSON:API Paints Your Bikeshed' }] }
    expect(actual.data).to eq(expected)
  end

  it 'defaults to creating a data field' do
    payload = { 'data' => [{ 'type' => 'post', 'id' => 1, 'attributes' => { 'title' => 'Deserializing for dummies' } }] }
    klass = Class.new(JSONAPI::Deserializable::Payload) do
      data
    end

    actual = klass.call(payload)
    # expect(actual.data[:data]).to(all(be_a(JSONAPI::Deserializable::Resource)))


  end
end
