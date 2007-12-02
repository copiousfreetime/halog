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
