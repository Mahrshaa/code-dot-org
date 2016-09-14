# == Schema Information
#
# Table name: professional_learning_partners
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  contact_id :integer          not null
#  urban      :boolean
#
# Indexes
#
#  index_professional_learning_partners_on_name_and_contact_id  (name,contact_id) UNIQUE
#

class ProfessionalLearningPartner < ActiveRecord::Base
  belongs_to :contact, class_name: 'User'
end
