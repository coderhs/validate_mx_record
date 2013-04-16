require 'active_record'
require 'resolv'

module Rubykitchen
	module ValidatesMxRecord
		module Validator
			class MxRecordValidator < ActiveModel::EachValidator
				def validate_each(record, attribute, value)
					if system("ping -c 1 google.com") then
					  mail_servers = Resolv::DNS.open.getresources(value.split('@')[1], Resolv::DNS::Resource::IN::MX)
					  regex_check = value =~ /\A[\w+\_.]+@[a-z\d\-.]+\.[a-z]+\z/i
                                          if mail_servers.empty? || !regex_check then
						  record.errors[attribute] << "Does not have a MX record assosiated with mail id"
					  end
					else
						record.errors[attribute] << "No active internet connection"
					end
				end
			end
		end

		module ClassMethods
			def validates_mx_record_of(*attr_names)
				validates_with ActiveRecord::Base::MxRecordValidator, _merge_attributes(attr_names)
			end
		end
	end
end

ActiveRecord::Base.send(:include, Rubykitchen::ValidatesMxRecord::Validator)
ActiveRecord::Base.send(:extend, Rubykitchen::ValidatesMxRecord::ClassMethods)
