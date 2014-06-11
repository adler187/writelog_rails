class WsdlController < ApplicationController
    def index
        @soap_endpoint = "http://#{request.env['SERVER_NAME']}:#{request.port}#{soap_action_path}"
        respond_to do |format|
            format.xml
        end
    end
end
