require 'bindata'
require 'dash/identifier'

module Dash
  class PsshBox < BinData::Record
    endian :big

    uint32 :total_size
    uint32 :type
    uint8  :version
    array  :flags, type: :uint8, initial_length: 3
    identifier :system_id
    uint32 :num_kids

    #identifier :first_kid
    #identifier :second_kid
    array :kids, type: :identifier, initial_length: :num_kids
  end
end