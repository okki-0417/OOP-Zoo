# frozen_string_literal: true

class ListType < ActiveModel::Type::Value
  def initialize(load:, dump:)
    super()
    @load = load
    @dump = dump
  end

  def cast(value)
    items = value.is_a?(Array) ? value : value.to_s.split(',')
    items.filter_map { |item| item.is_a?(String) || item.is_a?(Symbol) ? @load.call(item) : item }
  end

  def serialize(value)
    cast(value).map { |item| @dump.call(item) }.join(',')
  end
end
