class Rig < ActiveRecord::Base
  attr_accessible :label, :letter, :receive_frequency, :rig_number, :station, :transmit_frequency, :mode
  
  def to_soap_rig
    {
        station: station,
        networkLetter: letter,
        label: label,
        rigNumber: rig_number,
        xmitFreq: transmit_frequency,
        recvFreq: receive_frequency,
        mode: mode
    }
  end
end
