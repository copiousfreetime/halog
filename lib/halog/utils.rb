class Object
    def hash_of_fields(field_list)
        h = {}
        field_list.each do |field|
            value = self.send(field)
            h[field] = value
        end
        return h
    end
end