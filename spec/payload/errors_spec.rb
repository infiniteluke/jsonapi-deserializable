require 'spec_helper'

describe JSONAPI::Deserializable::Payload, '.errors' do
  it 'creates corresponding field' do
    payload = { 'errors' => [{ 'status' => 404, 'title' => 'Not Found'}, { 'status' => 418, 'title' => 'I\'m a teapot'}] }
    # Use a errors block that provides some default errors (author)
    klass = Class.new(JSONAPI::Deserializable::Payload) do
      errors { |e| e.merge({ 'meta' => { 'tip' => 'Don\'t worry. We all make mistakes' } }) }
    end

    actual = klass.call(payload)

    expected = { errors: [
      { 'status' => 404, 'title' => 'Not Found', 'meta' => { 'tip' => 'Don\'t worry. We all make mistakes' } },
      { 'status' => 418, 'title' => 'I\'m a teapot', 'meta' => { 'tip' => 'Don\'t worry. We all make mistakes' } }
    ] }
    expect(actual.errors).to eq(expected)
  end

  it 'defaults to creating a meta field' do
    payload = { 'errors' => [{ 'status' => 404, 'title' => 'Not Found'}] }
    klass = Class.new(JSONAPI::Deserializable::Payload) do
      errors
    end

    actual = klass.call(payload)

    expected = { errors: [{ 'status' => 404, 'title' => 'Not Found'}] }
    expect(actual.errors).to eq(expected)
  end
end
