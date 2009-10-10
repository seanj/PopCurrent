module ActiveRecord
  module Validations
    module ClassMethods
      def validates_no_profanity(*attr_names)
        @naughty_words = ['fuck','shit','piss','cunt','twat','cock']
        @replace_with = ['f*ck','sh*t','p*ss','c*nt','tw*t','c*ck']
        validates_each(attr_names) do |record, attr_name,value|
          @naughty_words.each do |cuss|
            if value.length > 0
              value.gsub!( /#{cuss}/i,
                @replace_with[@naughty_words.index(cuss)])
            end
          end
        end
      end
    end
  end
end