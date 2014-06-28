class HomeController < ApplicationController
  def index
    @lastid = params[:lastid] || (Qso.last.id - 100)
    
    @qsos = Qso.where('id > ?', @lastid).limit(100)
    
    @lastid = @qsos.last.id unless @qsos.empty?
    
    @rigs = Rig.all
    
    @total_qsos = 0
    @total_points = 0
    
    @scores = []
    Qso.valid_bands.each do |band|
        ssb_count = Qso.where(band_key: Qso.band_keys(band)).where(mode_key: Qso.phone_mode_key).count
        cw_count = Qso.where(band_key: Qso.band_keys(band)).where(mode_key: Qso.cw_mode_key).count
        dig_count = Qso.where(band_key: Qso.band_keys(band)).where(mode_key: Qso.dig_mode_key).count
        
        ssb_points = ssb_count
        cw_points = cw_count*2
        dig_points = dig_count*2
        
        band_qsos = ssb_count + cw_count + dig_count
        band_points = ssb_points + cw_points + dig_points
        
        @scores << {
          name: Qso.band_to_s(band),
          ssb: ssb_count,
          cw: cw_count,
          dig: dig_count,
          qsos: band_qsos,
          points: band_points
        }
        
        @total_points += band_points
        @total_qsos += band_qsos
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end
end
