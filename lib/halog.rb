module HALog
    
    ROOT_DIR    = File.expand_path(File.join(File.dirname(__FILE__),"..")).freeze
    LIB_DIR     = File.join(ROOT_DIR,"lib").freeze
    DATA_DIR    = File.join(ROOT_DIR,"data").freeze

    # 
    # Utility method to require all files ending in .rb in the directory
    # with the same name as this file minus .rb
    #
    def require_all_libs_relative_to(fname)
        prepend   = File.basename(fname,".rb")
        search_me = File.join(File.dirname(fname),prepend)
     
        Dir.entries(search_me).each do |rb|
            if File.extname(rb) == ".rb" then
                require "#{prepend}/#{File.basename(rb,".rb")}"
            end
        end
    end 
    module_function :require_all_libs_relative_to

end

HALog.require_all_libs_relative_to(__FILE__)
