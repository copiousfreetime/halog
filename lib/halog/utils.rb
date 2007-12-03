class Object
    def hash_of_fields(field_list)
        h = {}
        field_list.each do |field|
            begin
                h[field] = self.send(field)
            rescue NoMethodError
            end
        end
        return h
    end
end

module Util

  # essentially this is strfbytes from facets
  def num_to_bytes(num,fmt="%.2f")
     case
      when num < 1024
        "#{num} bytes"
      when num < 1024**2
        "#{fmt % (num.to_f / 1024)} KB"
      when num < 1024**3
        "#{fmt % (num.to_f / 1024**2)} MB"
      when num < 1024**4
        "#{fmt % (num.to_f / 1024**3)} GB"
      when num < 1024**5
        "#{fmt % (num.to_f / 1024**4)} TB"
      else
        "#{num} bytes"
      end
  end

  def hms_from_seconds(seconds)
      hms = [0, 0, 0]
      hms[2] = seconds % 60
      min_left = (seconds - hms[2]) / 60
    
      hms[1]    = min_left % 60
      hms[0]    = (min_left - hms[1]) / 60
      return "%02d:%02d:%02d" % hms
  end
end