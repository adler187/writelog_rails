
class ArrayOfint < WashOut::Type
    map 'contest26:int' => [:integer]
    
    type_name 'ArrayOfint'
    namespace 'contest26'
end

class ArrayOfstring < WashOut::Type
    map :string => [:string]
    
    type_name 'ArrayOfstring'
end

class QsoIdVersion < WashOut::Type
    map 'contest25:version' => :integer,
        'contest25:updatedBy' => :string,
        'contest25:id' => :string
    
    type_name 'QsoIdVersion'
    
    namespace 'contest25'
end

class SoapQso < WashOut::Type
    map 'contest25:time64H' => :integer,
        'contest25:time64L' => :integer,
        'contest25:xmitFreq' => :double,
        'contest25:recvFreq' => :double,
        'contest25:band' => :integer,
        'contest25:station' => :string,
        'contest25:mode' => :integer,
        'contest25:dupe' => :integer,
        'contest25:serial' => :integer,
        'contest25:qsoparts' => ArrayOfstring,
        'contest25:version' => :integer,
        'contest25:idKey' => :string,
        'contest25:updatedBy' => :string
    
    type_name 'Qso'
    
    namespace 'contest25'
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

class RigFrequencyOut < WashOut::Type
    map 'contest25:station' => :string,
        'contest25:networkLetter' => :integer,
        'contest25:label' => :string,
        'contest25:rigNumber' => :integer,
        'contest25:xmitFreq' => :double,
        'contest25:recvFreq' => :double,
        'contest25:mode' => :integer
    
    type_name 'RigFrequency'
    
    namespace 'contest25'
end

class ArrayOfQso < WashOut::Type
    map 'contest25:Qso' => [SoapQso]
    
    type_name 'ArrayOfQso'
end

class ArrayOfQsoIdVersion < WashOut::Type
    map 'contest25:QsoIdVersion' => [QsoIdVersion]
    
    type_name 'ArrayOfQsoIdVersion'
    
    namespace 'contest25'
end

class ArrayOfRigFrequency < WashOut::Type
    map :RigFrequency => [RigFrequency]
    
    type_name 'ArrayOfRigFrequency'
end

class ArrayOfRigFrequencySend < WashOut::Type
    map 'contest25:RigFrequency' => [RigFrequencyOut]
    
    type_name 'ArrayOfRigFrequency'
end

class QsoUpdate < WashOut::Type
    map 'contest25:qsoArray' => ArrayOfQso,
        'contest25:logState' => :integer
    
    type_name 'QsoUpdate'
    
    namespace 'contest25'
end

class LogSummary < WashOut::Type
    map 'contest25:logState' => :integer,
        'contest25:logSummaryIds' => ArrayOfQsoIdVersion
    
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
                 additional_namespaces: {
                     'contest25' => 'http://schemas.datacontract.org/2004/07/ContestQsos',
                     'contest26' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays'
                 }
    
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
        
        render :soap => { 'tns:ColumnNamesToIndicesResult' => { 'contest26:int' => column_indices } }
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
            
            qso_parts = qso[:qsoparts][:string]
            new_qso.operating_class = qso_parts[0]
            new_qso.section = qso_parts[1]
            new_qso.c_field = ""
            new_qso.country_prefix = qso_parts[3]
            
            new_qso.save
        end
    end
    
    soap_action 'AddAndGetLogSummary',
            :args => { :SessionId => :string, :QsoAddArray => ArrayOfQso, :OldState => :integer, :MaxRequested => :integer },
            :return => { 'tns:AddAndGetLogSummaryResult' => LogSummary },
            :response_tag => 'AddAndGetLogSummaryResponse',
            :to => :add_and_get_log_summary
    
    def add_and_get_log_summary2
        render file: 'soap/add_and_get_log_summary.xml.erb', content_type: 'text/xml'
    end
    
    def add_and_get_log_summary
        old_log_state = params[:OldState]
        new_qsos = params[:QsoAddArray][:Qso] || []
        max_requested = params[:MaxRequested]
        summary_ids = []
        
        new_log_state = old_log_state
        
        qsos_in_update = Qso.where('id > ?', old_log_state).limit(max_requested)
        qsos_in_update.each do |qso|
            new_log_state = qso.id
            
            summary_ids << qso.to_soap_qso_id :contest25
        end
        
        last_log_added_id = add_qsos(new_qsos)
        
        # We're up to date if we've given the client back all the
        # qsos in the database, since their last update. This would
        # not be the case if there are more qsos than their max_requested
        # or another client inserted a record since our query
        new_log_state = Qso.last.id if last_log_added_id == (new_log_state + new_qsos.length)
        
        render :soap => { 'tns:AddAndGetLogSummaryResult' => { 'contest25:logState' => new_log_state, 'contest25:logSummaryIds' => { 'contest25:QsoIdVersion' => summary_ids } } }
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
            
            qso_array << qso.to_soap_qso :contest25
        end
        
        last_log_added_id = add_qsos(new_qsos)
        
        # We're up to date if we've given the client back all the
        # qsos in the database, since their last update. This would
        # not be the case if there are more qsos than their max_requested
        # or another client inserted a record since our query
        new_log_state = Qso.last.id if last_log_added_id == (new_log_state + new_qsos.length)
        
        render :soap => { 'tns:AddAndGetQsoResult' => { 'contest25:qsoArray' => { 'contest25:Qso' => qso_array }, 'contest25:logState' => new_log_state } }
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
                qso_array << qso.to_soap_qso :contest25
            end
            
            render :soap => { 'tns:getQsosByKeyArrayResult' => { 'contest25:qsoArray' => { 'contest25:Qso' => qso_array }, 'contest25:logState' => log_state } }
        rescue ActiveRecord::RecordNotFound
            # TODO: throw a SOAP exception here
        end
    end
    
    soap_action 'ExchangeFrequencies',
            :args => { :IncomingFreqs => ArrayOfRigFrequency },
            :return => { 'tns:ExchangeFrequenciesResult' => ArrayOfRigFrequencySend },
            :response_tag => 'ExchangeFrequenciesResponse',
            :to => :exchange_frequencies
    
    def exchange_frequencies
        rig_array_in = params[:IncomingFreqs][:RigFrequency] || []
        rig_array_out = []
        
        rig_array_in.each do |rig_info|
            rig = Rig.where(letter: rig_info[:networkLetter]).where(rig_number: rig_info[:rigNumber]).first_or_create
            
            rig.station = rig_info[:station]
            rig.label = rig_info[:label]
            rig.mode = rig_info[:mode]
            rig.transmit_frequency = rig_info[:xmitFreq]
            rig.receive_frequency = rig_info[:recvFreq]
            
            rig.save
        end

        Rig.where('updated_at < ?', 10.minutes.ago).delete_all
        
        Rig.all.each do |rig|
            rig_array_out << rig.to_soap_rig(:contest25)
        end
        
        render :soap => { 'tns:ExchangeFrequenciesResult' => { 'contest25:RigFrequency' => rig_array_out } }
    end
end
