class Role

  SYSTEM_ROLES ={
                  "local_system_administrator" => 'Add a logo, set the district key, add users, add schools,
                  assign roles, add students, enroll students, import files, set district abbreviation (formerly district admin)',
                  "content_admin" => 'Setup Goals, Objectives, Categories, Interventions, Tiers, Checklists, and Progress Monitors',
                  "school_admin" => 'Create groups, assign students and groups, maintain quicklist',
                  "regular_user" => 'Regular user of SIMS',
                  "news_admin"  => 'Create and edit news items that appear on the left' ,
                }


  ADMIN_ROLES = ["local_system_administrator", "school_admin"]

  ROLES = %w{ local_system_administrator content_admin school_admin regular_user news_admin}
  CSV_HEADERS = [:district_user_id]

  HELP = {
    "local_system_administrator" => [{:name => "Change your logo and url", :url=> "/help/edit_district"}]
  }

  HELP.default = []




#  acts_as_list # :scope =>[:district_id,:state_id, :country_id, :system]  need to fix this
#  named_scope :system, :conditions => {:district_id => nil}


  def self.cache_key
    Digest::MD5.hexdigest(constants.collect{|c| const_get(c)}.to_s)
  end


  def self.mask_to_roles(mask)
    roles=ROLES.reject{ |r| (mask || 0)[ROLES.index(r)].zero?}
    roles.singleton_class.send(:define_method, "<<") do
      puts 'You probably want to use += instead'
     #Switching to rails 3 would allow me to redefine array as an association
      super
    end
  roles
  end

  def self.roles_to_mask(roles=[])
    (Array(roles) & ROLES).map { |r| 1 << ROLES.index(r) }.sum
  end

  def self.has_controller?(controller, roles)
    Right::RIGHTS.values_at(*roles).flatten.include?(controller)
  end

  def self.add_users(name, users)
    unless ROLES.index(name).nil?
      User.update_all("roles_mask = roles_mask | #{1 << ROLES.index(name)}",{:id=>Array(users)})
    end
  end

  def self.remove_users(name,users)
    unless ROLES.index(name).nil?
      User.update_all("roles_mask = roles_mask & ~#{1 << ROLES.index(name)}",{:id=>Array(users)})

    end

  end
end
