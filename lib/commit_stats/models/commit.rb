module CommitStats
  class Commit < ActiveRecord::Base
    before_validation_on_create :update_testcase_count
    validates_uniqueness_of :sha
    serialize :changeset, Array
    
    attr_accessor :diff
    
    def self.total_testcases
      sum 'testcase_count'
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
      changeset.detect { |path| !(path =~ /vendor|lib/) && path =~ /_spec\.rb|[Tt]est\.java|test\.html/ }
    end
  
    def cowboy?
      pair && pair.split(/[\/,]/).size == 1
    end
      
    def to_a
      [ date.strftime( "%Y,%m,%d" ), 
        date.strftime( "%H,%M,%S" ),
        svn_rev,
        pair,
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
        if line =~ /^\+\s*(it\s+['"]|def test|@Test)/  
          accumulator + 1
        else
          accumulator
        end
      }
    end
  end
end
