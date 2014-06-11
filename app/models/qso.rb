class Qso < ActiveRecord::Base
  attr_accessible :band,
                  :c_field,
                  :country_prefix,
                  :dupe,
                  :id_key,
                  :mode,
                  :operating_class,
                  :receive_frequency,
                  :section,
                  :serial,
                  :station,
                  :time_upper,
                  :time_lower,
                  :transmit_frequency,
                  :updated_by,
                  :version
  
  def time
#     time_lower = -1423705715
#     time_upper = 30373443
#     time = (time_upper << 32) | (time_lower & 0xFFFFFFFF)
    (time_upper << 32) | (time_lower & 0xFFFFFFFF)
  end
  
  def to_soap_qso
    { 
        time64H: time_upper,
        time64L: time_lower,
        xmitFreq: transmit_frequency,
        recvFreq: receive_frequency,
        band: band,
        station: station,
        mode: mode,
        dupe: dupe,
        serial: serial,
        version: version,
        idKey: id_key,
        updatedBy: updated_by,
        qsoparts: [
            operating_class,
            section,
            c_field,
            country_prefix
        ]
    }
  end
end

