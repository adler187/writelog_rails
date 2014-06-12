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
    
    def to_soap_qso(namespace)
        { 
            "#{namespace.to_s}:time64H" => time_upper,
            "#{namespace.to_s}:time64L" => time_lower,
            "#{namespace.to_s}:xmitFreq" => transmit_frequency,
            "#{namespace.to_s}:recvFreq" => receive_frequency,
            "#{namespace.to_s}:band" => band,
            "#{namespace.to_s}:station" => station,
            "#{namespace.to_s}:mode" => mode,
            "#{namespace.to_s}:dupe" => dupe,
            "#{namespace.to_s}:serial" => serial,
            "#{namespace.to_s}:version" => version,
            "#{namespace.to_s}:idKey" => id_key,
            "#{namespace.to_s}:updatedBy" => updated_by,
            "#{namespace.to_s}:qsoparts" => [
                operating_class,
                section,
                c_field,
                country_prefix
            ]
        }
    end
    
    def to_soap_qso_id(namespace)
        {
            "#{namespace.to_s}:id" => qso.id_key,
            "#{namespace.to_s}:version" => qso.version,
            "#{namespace.to_s}:updatedBy" => qso.updated_by
        }
    end
end

