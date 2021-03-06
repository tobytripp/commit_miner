module CommitStats
  class Commit < ActiveRecord::Base
    before_validation_on_create :update_testcase_count
    validates_uniqueness_of :sha
    serialize :changeset, Array
    
    attr_accessor :diff
    
    named_scope :bugs, :conditions => "caused_bug IS NOT NULL";
    
    def self.total_testcases
      sum 'testcase_count'
    end
  
    def self.most_recent
      find :first, :order => "date DESC"
    end
  
    def pair=( pair_data )
      return if pair_data.nil?
      self.pair1, self.pair2 = pair_data.split( /,|\/|\\/ )
    end
    
    def bug!( bug_name )
      bug_list = self.caused_bug || ""
      bug_list = bug_list.split ","
      new_list = [bug_list, bug_name].flatten.map(&:strip).uniq
      self.update_attribute( :caused_bug, new_list.join( ", " ) )
    end
      
    def diff
      @diff ||= ""
    end
  
    def changeset
      self[:changeset] ||= []
    end
    
    def code_extension
      changeset.detect { |path| path =~ /[.](js|rb|java)$/ }
      $1
    end
  
    def untested?
      !tested?
    end
    
    def tested?
      changeset.detect { |path|
        !(path =~ /vendor|lib/) &&
        path =~ /_spec\.rb|[Tt]est\.java|test\.html|_spec\.js/
      }
    end
  
    def cowboy?
      pair2.blank?
    end
      
    def to_a
      [ date.strftime( "%Y,%m,%d" ), 
        date.strftime( "%H,%M,%S" ),
        svn_revision,
        pair1,
        pair2,
        author,
        cowboy?  ? '1' : '0',
        !tested? ? '1' : '0',
        code_extension,
        message ]
    end
  
    def to_s
      to_a.join( "\t" )
    end
    
    protected
    
    def update_testcase_count
      self.testcase_count = self.diff.inject(0) { |accumulator, line|
        if line =~ /^\+\s*(it\(?\s+['"]|def test|@Test)/  
          accumulator + 1
        else
          accumulator
        end
      }
    end
  end
end
