# == Schema Information
# Schema version: 20101101011500
#
# Table name: intervention_participants
#
#  id              :integer(4)      not null, primary key
#  intervention_id :integer(4)
#  user_id         :integer(4)
#  role            :integer(4)      default(1)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'ruport'

class InterventionParticipant < ActiveRecord::Base
  belongs_to :user
  belongs_to :intervention

  delegate :email, :fullname, :to => '(user or return nil)'
  attr_writer :skip_email

  after_create :send_new_participant_email

  validates_uniqueness_of :user_id, :scope => :intervention_id, :message => "has already been assigned to this intervention"
  validates_presence_of :user_id, :role, :intervention_id
  acts_as_reportable # if defined? Ruport

  AUTHOR = -1
  IMPLEMENTER = 0
  PARTICIPANT = 1

  ROLES = %w{Implementer Participant Author}
  scope :implementer, where(:role => IMPLEMENTER)
  define_statistic :participants , :count => :all, :joins => :user
  define_statistic :users_as_participant , :count => :all,:select => 'distinct user_id', :joins => :user

  RoleStruct = Struct.new(:id, :name)

  def role_title
    ROLES[role]
  end

  def toggle_role!
    if self.role == IMPLEMENTER
      self.role = PARTICIPANT
    else
      self.role = IMPLEMENTER
    end
    save!

  end

  def self.roles
    [RoleStruct.new(IMPLEMENTER, ROLES[IMPLEMENTER]), RoleStruct.new(PARTICIPANT, ROLES[PARTICIPANT])]

  end

  protected

  def before_create
    if intervention.created_at == intervention.updated_at
      @skip_email = true if Time.now - intervention.created_at < 1.second
    end
      @skip_email ||= caller.to_s.include?("grouped_progress_entry")
      true
  end

  def send_new_participant_email
    unless @skip_email
      Notifications.deliver_intervention_participant_added(self)
    end
  end
end
