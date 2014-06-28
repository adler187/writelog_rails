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
  
  MODE_LSB = 49
  MODE_USB = 50
  MODE_CW = 51
  MODE_FM = 52
  MODE_AM = 53
  MODE_DIG = 54
  
  BAND_160M = [0, 10, 20]
  BAND_80M = [1, 11, 21]
  BAND_40M = [2, 12, 22]
  BAND_20M = [3, 13, 23]
  BAND_15M = [4, 14, 24]
  BAND_10M = [5, 15, 25]
  BAND_6M = [6, 16, 26]
  BAND_30M = [7, 17, 27]
  BAND_17M = [8, 18, 28]
  BAND_12M = [9, 19, 29]
  BAND_2M = [30, 31]
  BAND_1M = [32, 33]
  BAND_70CM = [34, 35]
  BAND_33CM = [36, 37]
  
  VALID_BANDS = [
    :eighty,
    :forty,
    :twenty,
    :fifteen,
    :ten
  ]
  
  def self.valid_bands
    VALID_BANDS
  end
  
  def self.band_keys(band)
    case band
    when :onesixty
      return BAND_160M
    when :eighty
      return BAND_80M
    when :forty
      return BAND_40M
    when :twenty
      return BAND_20M
    when :fifteen
      return BAND_15M
    when :ten
      return BAND_10M
    end
  end
  
  def self.band_to_s(band)
    case band
    when :onesixty
      return '160m'
    when :eighty
      return '80m'
    when :forty
      return '40m'
    when :twenty
      return '20m'
    when :fifteen
      return '15m'
    when :ten
      return '10m'
    end
  end
  
  def self.phone_mode_key
    [MODE_LSB, MODE_USB]
  end
  
  def self.cw_mode_key
    MODE_CW
  end
  
  def self.dig_mode_key
    MODE_DIG
  end
  
  def mode
    case mode_key
    when MODE_LSB
      'LSB'
    when MODE_USB
      'USB'
    when MODE_CW
      'CW'
    when MODE_FM
      'FM'
    when MODE_AM
      'AM'
    when MODE_DIG
      'DIG'
    else
      "Unkown Mode #{mode_key}"
    end
  end
  
  def mode=(val)
  end
  
  def band
    case band_key
    when *BAND_160M
      '160m'
    when *BAND_80M
      '80m'
    when *BAND_40M
      '40m'
    when *BAND_20M
      '20m'
    when *BAND_15M
      '15m'
    when *BAND_10M
      '10m'
    when *BAND_6M
      '6m'
    when *BAND_30M
      '30m'
    when *BAND_17M
      '17m'
    when *BAND_12M
      '12m'
    when *BAND_2M
      '2m'
    when *BAND_1M
      '1.25m'
    when *BAND_70CM
      '70cm'
    when *BAND_33CM
      '33cm'
      
    when 38
      '????'
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
      'Dupe'
      
    when 66
      'Out of Band'
      
    when 88
      'Unclaimed'
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

    DateTime.strptime(unix_time.to_s, '%s').strftime('%Y-%m-%d %H:%M:%S')
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
  
  def username
    id_key[13..-1]
  end
  
  def network_letter
    id_key[0]
  end
  
  def network_display_name
    rig = Rig.where(username: username).first
    
    return rig.network_display_name unless rig.nil?
    
    username
  end
  
  def points
    case mode_key
    when 49, 50, 52, 53
      return 1
    else
      return 2
    end
  end
end

