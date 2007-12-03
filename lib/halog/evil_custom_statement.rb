require 'sqlite3'
require 'stringio'

module HALog
  
  # this SQLite3 statement generates a method which does the bindings
  # this turns out to be a bit faster than looping over the available 
  # fields and doing a dynamic call.
  class EvilCustomStatement < ::SQLite3::Statement    

    class << self
      def insert_sql
        columns     = self::FIELDS.collect { |f| f.first }.join(',')
        params      = self::FIELDS.collect { |f| ":#{f.first}" }.join(',')
        @insert_sql = "INSERT INTO #{self::TABLE}(#{columns}) VALUES (#{params})"
      end
      
      def execute_method_str
        eval_me = StringIO.new
        eval_me.puts <<-CODE
         def execute( *params ) 
          must_be_open!
          reset! if active?

          p = params.flatten.first
          
        CODE
        
        self::FIELDS.each_with_index do |field,idx|
          if field.last == 'bind_int' then
            eval_me.puts <<-CODE3
              if p['#{field.first}'] === Bignum then
                @driver.bind_int64( @handle, #{idx+1}, p['#{field.first}'] )
              else 
                @driver.bind_int( @handle, #{idx+1}, p['#{field.first}'] )
              end
              
            CODE3
          else
            eval_me.puts <<-CODE4
              @driver.#{field.last}( @handle, #{idx+1}, p['#{field.first}'] )
            CODE4
          end
        end
        
        eval_me.puts <<-CODE2
          @results = ::SQLite3::ResultSet.new(@db, self)

          if block_given?
            yield @results
          else
            return @results
          end
        end
        CODE2
        
        return eval_me.string
      end
    end
  
    def initialize( db )
      super(db,self.class.insert_sql)
      reset!
      instance_eval self.class.execute_method_str
    end
  end
end