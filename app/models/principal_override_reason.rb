# == Schema Information
# Schema version: 20101027022939
#
# Table name: principal_override_reasons
#
#  id          :integer(4)      not null, primary key
#  district_id :integer(4)
#  reason      :text
#  autopromote :boolean(1)
#  created_at  :datetime
#  updated_at  :datetime
#

class PrincipalOverrideReason < ActiveRecord::Base
  belongs_to :district
end
