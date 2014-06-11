class QsoIdVersion < WashOut::Type
    map :version => :integer,
        :updatedBy => :string,
        :id => :string
    
    type_name 'QsoIdVersion'
    
    attr_accessor :id, :version, :updatedBy
end

class SoapQso < WashOut::Type
    map :time64H => :integer,
        :time64L => :integer,
        :xmitFreq => :double,
        :recvFreq => :double,
        :band => :integer,
        :station => :string,
        :mode => :integer,
        :dupe => :integer,
        :serial => :integer,
        :qsoparts => [:string],
        :version => :integer,
        :idKey => :string,
        :updatedBy => :string
    
    type_name 'Qso'
end

class RigFrequency < WashOut::Type
    map :station => :string,
        :networkLetter => :integer,
        :label => :string,
        :rigNumber => :integer,
        :xmitFreq => :double,
        :recvFreq => :double,
        :mode => :integer
    
    type_name 'RigFrequency'
end

class ArrayOfQso < WashOut::Type
    map :Qso => [SoapQso]
    
    type_name 'ArrayOfQso'
end

class ArrayOfQsoIdVersion < WashOut::Type
    map :elements => [QsoIdVersion]
    
    type_name 'ArrayOfQsoIdVersion'
    
    attr_accessor :elements
    
    namespace 'contest25'
end

class ArrayOfint < WashOut::Type
    map :int => [:integer]
    
    type_name 'ArrayOfint'
    attr_accessor :int
end

class ArrayOfstring < WashOut::Type
    map :string => [:string]
    
    type_name 'ArrayOfstring'
    attr_accessor :string
end

class ArrayOfRigFrequency < WashOut::Type
    map :elements => [RigFrequency]
    
    type_name 'ArrayOfRigFrequency'
    attr_accessor :elements
end

class QsoUpdate < WashOut::Type
    map :qsoArray => ArrayOfQso,
        :logState => :integer
    
    type_name 'QsoUpdate'
    
    attr_accessor :qsoArray, :logState
end

class LogSummary < WashOut::Type
    map :logState => :integer,
        :logSummaryIds => ArrayOfQsoIdVersion
    
    type_name 'LogSummary'
    
    namespace 'contest25'
end

class GetQsosByKeyArrayResult < WashOut::Type
    map :value => LogSummary
    
    type_name 'getQsosByKeyArrayResult'
end

class SoapController < ApplicationController
    soap_service namespace: 'urn:ContestQsos2',
                 soap_action_routing: false,
                 additional_namespaces: {"contest25" => 'http://schemas.datacontract.org/2004/07/ContestQsos' }
    
    soap_action 'GetSessionId',
            :args => nil,
            :return => { 'tns:GetSessionIdResult' => :string },
            :response_tag => 'GetSessionIdResponse',
            :to => :get_session_id
    
    def get_session_id
        render :soap => { 'tns:GetSessionIdResult' => '123456' }
    end
    
    soap_action 'ColumnNamesToIndices',
            :args => { :SessionId => :string, :ColumnNames => ArrayOfstring },
            :return => { 'tns:ColumnNamesToIndicesResult' => ArrayOfint },
            :response_tag => 'ColumnNamesToIndicesResponse',
            :to => :column_names_to_indices
    
    def column_names_to_indices
        session_id = params[:SessionId]
        column_names = params[:ColumnNames]
        
        puts column_names
        
        column_names = column_names[:string]
        
        column_indices = []
        i = 4
        column_names.each do |column_name|
            case column_name
            when 'APP_WRITELOG_RCV'
                column_indices.push 0
            when 'ARRL_SECT'
                column_indices.push 1
            when 'APP_WRITELOG_C'
                column_indices.push 2
            when 'APP_WRITELOG_PREF'
                column_indices.push 3
            else
                column_indices.push i
                i += 1
            end
        end
        
        render :soap => { 'tns:ColumnNamesToIndicesResult' => { :int => column_indices } }
    end
    
    soap_action 'AddAndGetLogSummary',
            :args => { :SessionId => :string, :QsoAddArray => ArrayOfQso, :OldState => :integer, :MaxRequested => :integer },
            :return => { 'tns:AddAndGetLogSummaryResult' => LogSummary },
            :response_tag => 'AddAndGetLogSummaryResponse',
            :to => :add_and_get_log_summary
    
    def add_and_get_log_summary2
        render file: 'soap/add_and_get_log_summary.xml.erb', content_type: 'text/xml'
    end
    
    def add_qsos(new_qsos)
        
        new_qsos.each do |qso|
            puts qso
            new_qso = Qso.new
            
            new_qso.time_upper = qso[:time64H]
            new_qso.time_lower = qso[:time64L]
            new_qso.transmit_frequency = qso[:xmitFreq]
            new_qso.receive_frequency = qso[:recvFreq]
            new_qso.band = qso[:band]
            new_qso.station = qso[:station]
            new_qso.mode = qso[:mode]
            new_qso.dupe = qso[:dupe]
            new_qso.serial = qso[:serial]
            new_qso.version = qso[:version]
            new_qso.id_key = qso[:idKey]
            new_qso.updated_by = qso[:updatedBy]
            
            qso_parts = qso[:qsoparts]
            new_qso.operating_class = qso_parts[0]
            new_qso.section = qso_parts[1]
            new_qso.c_field = qso_parts[2]
            new_qso.country_prefix = qso_parts[3]
            
            new_qso.save
        end
    end
    
    def add_and_get_log_summary
        old_log_state = params[:OldState]
        new_qsos = params[:QsoAddArray][:Qso] || []
        max_requested = params[:MaxRequested]
        summary_ids = []
        
        qsos_in_update = Qso.where('id > ?', old_log_state).limit(max_requested)
        qsos_in_update.each do |qso|
            summary_ids << { id: qso.id_key, version: qso.version, updatedBy: qso.updated_by }
        end
        
        add_qsos(new_qsos)
        
        new_log_state = 0
        new_log_state = Qso.last.id unless Qso.last.nil?
        
        render :soap => { 'tns:AddAndGetLogSummaryResult' => { :logState => new_log_state, :logSummaryIds => { :elements => summary_ids } } }
    end
    
    soap_action 'addAndGetQsos',
            :args => { :SessionId => :string, :QsoAddArray => ArrayOfQso, :OldState => :integer, :MaxRequested => :integer },
            :return => { 'tns:AddAndGetQsoResult' => QsoUpdate },
            :response_tag => 'AddAndGetQsoResponse',
            :to => :add_and_get_qsos
    
    def add_and_get_qsos
        old_log_state = params[:OldState]
        new_qsos = params[:QsoAddArray][:Qso] || []
        max_requested = params[:MaxRequested]
        
        qso_array = []
        
        new_log_state = old_log_state
        
        Qso.where('id > ?', old_log_state).limit(max_requested).each do |qso|
            new_log_state = qso.id
            
            qso_array << qso.to_soap_qso
        end
        
        last_log_added_id = add_qsos(new_qsos)
        
        # We're up to date if we've given the client back all the
        # qsos in the database, since their last update. This would
        # not be the case if there are more qsos than their max_requested
        # or another client inserted a record since our query
        new_log_state = Qso.last.id if last_log_added_id == (new_log_state + new_qsos.length)
        
        render :soap => { 'tns:AddAndGetQsoResult' => { :qsoArray => { :elements => qso_array }, :logState => new_log_state } }
    end
    
    soap_action 'getQsosByKeyArray',
            :args => { :SessionId => :string, :QsoKeyarray => ArrayOfstring },
            :return => { 'tns:getQsosByKeyArrayResult' => QsoUpdate },
            :response_tag => 'getQsosByKeyArrayResponse',
            :to => :get_qso_by_key_array
    
    def get_qso_by_key_array
        qso_keys = params[:QsoKeyarray] || []
        qso_array = []
        
        begin
            qso_keys.each do |key|
                qso = Qso.find_by! id_key: key
                qso_array << qso.to_soap_qso
            end
            
            render :soap => { 'tns:getQsosByKeyArrayResult' => { :qsoArray => qso_array, :logState => log_state } }
        rescue ActiveRecord::RecordNotFound
            # TODO: throw a SOAP exception here
        end
    end
    
    soap_action 'ExchangeFrequencies',
            :args => { :IncomingFreqs => ArrayOfRigFrequency },
            :return => { 'tns:ExchangeFrequenciesResult' => ArrayOfRigFrequency },
            :response_tag => 'ExchangeFrequenciesResponse',
            :to => :exchange_frequencies
    
    def exchange_frequencies
        rig_array_in = params[:IncomingFreqs][:elements] || []
        rig_array_out = []
        
        rig_array_in.each do |rig_info|
            rig = Rig.where(letter: rig_info[:networkLetter]).where(rig_number: rig_info[:rigNumber]).first_or_create do |rig|
#                 rig.letter = rig_info[:networkLetter]
#                 rig.rig_number = rig_info[:rigNumber]
                rig.station = rig_info[:station]
                rig.label = rig_info[:label]
                rig.mode = rig_info[:mode]
                rig.transmit_frequency = rig_info[:xmitFreq]
                rig.receive_frequency = rig_info[:recvFreq]
            end
            
            rig.save
        end
        
        Rig.where('updated_at < ?', 10.minutes.ago).delete_all
        
        Rig.all.each do |rig|
            rig_array_out << rig.to_soap_rig
        end
        
        render :soap => { 'tns:ExchangeFrequenciesResult' => { :rf_el => rig_array_out } }
    end
end
