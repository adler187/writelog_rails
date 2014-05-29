class Qso < WashOut::Type
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
end

class ArrayOfQso < WashOut::Type
    map :qso_el => [Qso]
end

class QsoIdVersion < WashOut::Type
    map :version => :integer,
        :updatedBy => :string,
        :id => :string
end

class QsoUpdate < WashOut::Type
    map :qsoArray => ArrayOfQso,
        :logState => :integer
end

class ArrayOfQsoIdVersion < WashOut::Type
    map :id_el => [QsoIdVersion]
end

class RigFrequency < WashOut::Type
    map :station => :string,
        :networkLetter => :integer,
        :label => :string,
        :rigNumber => :integer,
        :xmitFreq => :double,
        :recvFreq => :double,
        :mode => :integer
end

class LogSummary < WashOut::Type
    map :logState => :integer,
        :logSummaryIds => ArrayOfQsoIdVersion
end

class ArrayOfInt < WashOut::Type
    map :int => [:integer]
    
    attr_accessor :int
end

class ArrayOfstring < WashOut::Type
    map :string => [:string]
    
    attr_accessor :string
end

class ArrayOfRigFrequency < WashOut::Type
    map :rf_el => [RigFrequency]
end

class SoapController < ApplicationController
    soap_service namespace: 'urn:ContestQsos2', soap_action_routing: false
    
    soap_action 'GetSessionId',
            :args => nil,
            :return => { :GetSessionIdResult => :string },
            :to => :get_session_id
    
    def get_session_id
        render :soap => { :GetSessionIdResult => '123456' }
    end
    
    soap_action 'ColumnNamesToIndices',
            :args => { :SessionId => :string, :ColumnNames => {:string => [:string] } },
            :return => { :ColumnNamesToIndicesResult => {'contest26:int' => [:integer] }},
            :to => :column_names_to_indices
    
    def column_names_to_indices
#         session_id = params[:SessionId]
        column_names = params[:ColumnNames][:string]
        
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
        
        response = ArrayOfInt.new
        response.int = column_indices
        
        render :soap => { :ColumnNamesToIndicesResult => { 'contest26:int' => column_indices } }
    end
    
    soap_action 'addAndGetLogSummary',
            :args => { :SessionId => :string, :QsoAddArray => ArrayOfQso, :OldState => :integer, :MaxRequested => :integer },
            :return => { :response => LogSummary },
            :to => :add_and_get_log_summary
    
    def add_and_get_log_summary
        response = LogSummary.new
        
        response.logState = 1
        
        render :soap => response
    end
    
    soap_action 'AddAndGetQso',
            :args => { :SessionId => :string, :QsoAddArray => ArrayOfQso, :OldState => :integer, :MaxRequested => :integer },
            :return => { :response => QsoUpdate },
            :to => :add_and_get_qso
    
    def add_and_get_qso
        reponse = QsoUpdate.new
        
        render :soap => response
    end
    
    soap_action 'getQsosByKeyArray',
            :args => { :SessionId => :string, :QsoKeyarray => ArrayOfstring },
            :return => { :response => QsoUpdate },
            :to => :get_qso_by_key_array
    
    def get_qso_by_key_array
        response = QsoUpdate.new
        
        render :soap => response
    end
    
    soap_action 'ExchangeFrequencies',
            :args => { :IncomingFreqs => ArrayOfRigFrequency },
            :return => { :response => ArrayOfRigFrequency },
            :to => :exchange_frequencies
    
    def exchange_frequencies
        response ArrayOfRigFrequency.new
        
        render :soap => response
    end
end
