require 'sqlite3'
module SQLite3
  # this is a faster statement than the one that comes with sqlite.  
  # efficiency improvements:
  #
  #  * keeps a hash of parameter index positions
  #  * only calls must_be_open, reset! and active? once per statement execution
  #  * bind param is not called 2x for every binding
  #
  class FasterStatement < Statement
    def initialize( db, sql, utf16=false )
      super(db,sql,utf16)
      @param_index_cache = {}
    end

    def bind_params( *bind_vars )
      must_be_open!
      reset! if active?
      
      index = 1
      bind_vars.flatten.each do |var|
        if Hash === var
          var.each { |key, val| bind_param key, val}
        else
          bind_param index, var
          index += 1
        end
      end
    end

    def bind_param( param, value )
      
      if Fixnum === param then
        index = param
      else
        param = param.to_s
        param = ":#{param}" unless param[0] == ?:
        index = @param_index_cache[param] ||= @driver.bind_parameter_index( @handle, param )
        raise Exception, "no such bind parameter '#{param}'" if index == 0
      end

      case value
        when Bignum then
          @driver.bind_int64( @handle, index, value )
        when Integer then
          @driver.bind_int( @handle, index, value )
        when Numeric then
          @driver.bind_double( @handle, index, value.to_f )
        when Blob then
          @driver.bind_blob( @handle, index, value )
        when nil then
          @driver.bind_null( @handle, index )
        else
          @driver.bind_text( @handle, index, value )
      end
    end
  end
end
