class Rig < ActiveRecord::Base
  attr_accessible :label, :letter, :receive_frequency, :rig_number, :station, :transmit_frequency, :mode
  
  def to_soap_rig(namespace)
    {
        "#{namespace.to_s}:station" => station,
        "#{namespace.to_s}:networkLetter" => letter,
        "#{namespace.to_s}:label" => label,
        "#{namespace.to_s}:rigNumber" => rig_number,
        "#{namespace.to_s}:xmitFreq" => transmit_frequency,
        "#{namespace.to_s}:recvFreq" => receive_frequency,
        "#{namespace.to_s}:mode" => mode
    }
  end
end
