require 'sqlite3'
require 'stringio'

module HALog
  class CustomStatement < ::SQLite3::Statement    

    class << self
      def insert_sql
        columns     = self::FIELDS.collect { |f| f.first }.join(',')
        params      = self::FIELDS.collect { |f| ":#{f.first}" }.join(',')
        @insert_sql = "INSERT INTO #{self::TABLE}(#{columns}) VALUES (#{params})"
      end
    end

    def initialize( db )
      super(db,self.class.insert_sql)
      reset!
    end

    def execute( *params )
      must_be_open!
      reset! if active?

      p = params.flatten.first

      self.class::FIELDS.each_with_index do |field,idx|

        value  = p[field.first]
        method = field.last
        pos    = idx + 1

        if value then
          if method == 'bind_int' and value === Bignum then
            method = 'bind_int64'
          end
          @driver.send( method, @handle, pos, value )
        else
          @driver.bind_null( @handle, pos )
        end

      end

      @results = ::SQLite3::ResultSet.new(@db, self)

      if block_given?
        yield @results
      else
        return @results
      end

    end
  end
end
