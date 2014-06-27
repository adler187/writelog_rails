class HomeController < ApplicationController
  def index
    @lastid = params[:lastid] || 0
    
    @qsos = Qso.where('id > ?', @lastid).limit(10)
    
    @lastid = @qsos.last.id unless @qsos.empty?
    
    @rigs = Rig.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end
end
