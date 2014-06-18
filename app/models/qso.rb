class Qso < ActiveRecord::Base
    attr_accessible :band_key,
                    :c_field,
                    :country_prefix,
                    :dupe_key,
                    :id_key,
                    :mode_key,
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
    
    def mode=(val)
    end
    
    def band
        case band_key
        when 1
            '40m'
        when 11
            '80m'
        else
            "Unkown band #{band_key}"
        end
    end
    
    def band=(val)
    end
    
    def dupe
        case dupe_key
        when 32
            ''
        when 68
            'D'
            
        when 66
            'B'
        else
            "Unknown Dupe value #{dupe_key}"
        end
    end
    
    def dupe=(val)
    end
    
    def time
        lower = "%08x" % time_lower
        upper = "%08x" % time_upper
        
        time_hex = upper[-8..-1] + lower[-8..-1]
        
        time_pack = [time_hex].pack("H16")
        
        windows_time = time_pack.unpack("Q>")[0]
        
        unix_time = (windows_time / 10000000) - 11644473600
        
        DateTime.strptime(unix_time.to_s, '%s')
    end
    
    def to_soap_qso(namespace)
        { 
            "#{namespace.to_s}:time64H" => time_upper,
            "#{namespace.to_s}:time64L" => time_lower,
            "#{namespace.to_s}:xmitFreq" => transmit_frequency,
            "#{namespace.to_s}:recvFreq" => receive_frequency,
            "#{namespace.to_s}:band" => band_key,
            "#{namespace.to_s}:station" => station,
            "#{namespace.to_s}:mode" => mode_key,
            "#{namespace.to_s}:dupe" => dupe_key,
            "#{namespace.to_s}:serial" => serial,
            "#{namespace.to_s}:version" => version,
            "#{namespace.to_s}:idKey" => id_key,
            "#{namespace.to_s}:updatedBy" => updated_by,
            "#{namespace.to_s}:qsoparts" => { 'contest26:string' => [
                operating_class,
                section,
                c_field,
                country_prefix
            ] }
        }
    end
    
    def to_soap_qso_id(namespace)
        {
            "#{namespace.to_s}:id" => id_key,
            "#{namespace.to_s}:version" => version,
            "#{namespace.to_s}:updatedBy" => updated_by
        }
    end
end

