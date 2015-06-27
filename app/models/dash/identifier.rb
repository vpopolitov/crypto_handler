require 'bindata'

module Dash
  class Identifier < BinData::Primitive
    array :raw_id, type: :uint8, initial_length: 16

    def get
      self.raw_id.map { |i| i.value.to_s(16).rjust(2, '0') }.join
    end
  end
end