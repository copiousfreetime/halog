class Object
    def hash_of_fields(field_list)
        h = {}
        field_list.each do |field|
            begin
                value = self.send(field)
                h[field] = value
            rescue NoMethodError
            end
        end
        return h
    end
end