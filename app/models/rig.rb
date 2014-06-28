class Rig < ActiveRecord::Base
  attr_accessible :network_display_name, :network_letter, :receive_frequency, :rig_number, :username, :transmit_frequency, :mode_key
  
  def to_soap_rig(namespace)
    {
        "#{namespace.to_s}:station" => username,
        "#{namespace.to_s}:networkLetter" => network_letter,
        "#{namespace.to_s}:label" => network_display_name,
        "#{namespace.to_s}:rigNumber" => rig_number,
        "#{namespace.to_s}:xmitFreq" => transmit_frequency,
        "#{namespace.to_s}:recvFreq" => receive_frequency,
        "#{namespace.to_s}:mode" => mode_key
    }
  end
  
  def mode
    case mode_key
      when 49
        'LSB'
      when 50
          'USB'
      when 51
          'CW'
      when 52
          'FM'
      when 53
          'AM'
      when 54
          'DIG'
      else
          "Unkown Mode #{mode_key}"
    end
  end
end
