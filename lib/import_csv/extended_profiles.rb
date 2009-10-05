class ExtendedProfile
  CSV_HEADERS = [:id_district, :arbitrary]
end

module ImportCSV::ExtendedProfiles
  def load_arbitrary_extended_profile_content_from_csv file_name
    @students = ids_by_id_district Student

    # @role=Role.find_by_name(role) or return false
    # @existing_users = @role.users.all(:conditions => ["district_id = ? and id_district is not null", @district.id],:select => "id, id_district")
    
    if load_extended_profiles_from_csv file_name
      # @desired_users = district.users(true).all(:select => "id, id_district", 
      # :conditions => ["district_id = ? and id_district is not null and id_district in (?) ", @district.id,
      # @ids.compact]
      # )

      # # insert desired - existing
      # @role.users << (@desired_users  -@existing_users)
      # @extended_profile

      # # remove existing - desired
      # @role.users.delete(@existing_users - @desired_users)
    end
  end

  def load_siblings_extended_profile_content_from_csv file_name
    @students = ids_by_id_district Student
    load_siblings_from_csv file_name
  end

def load_siblings_from_csv file_name
  #REFACTOR and this probably shouldn't be done by line
    system(%Q{sed -i -e \"s/\\"/\\'\\'/\" #{file_name}}) 
    students_with_siblings = FasterCSV.read(file_name, ImportCSV::DEFAULT_CSV_OPTS).group_by{|e| e[:id_district]}
    students_with_siblings.each do |student_with_siblings|
      student_id = @students[student_with_siblings[0].to_i]
      next if student_id.blank?
      
      path = Student::EXTENDED_PROFILE_PATH  % [@district.id, student_id]
      FileUtils.mkdir_p(File.dirname(path))
      
      File.open("#{path}", 'w+') {|f| f << "<table>"
        student_with_siblings[1].each do |sibling|
          f << "<tr>"
          f << "<td>#{sibling[:firstname]} #{sibling[:middlename]} #{sibling[:lastname]}</td>"
          f << "<td>#{sibling[:studentnumber]}</td>"
          f << "<td>#{sibling[:schoolname]}</td>"
          f << "<td>#{sibling[:grade]}</td>"
          f << "<td>#{sibling[:age]}</td>"
          f << "</tr>"
        end
        f<< "</table>"
      }
    end
      
    @messages << "Successful import of #{File.basename(file_name)}"
  end


  def load_extended_profiles_from_csv file_name
    lines = FasterCSV.read(file_name, ImportCSV::DEFAULT_CSV_OPTS)
    FileUtils.rm_rf(File.dirname(Student::EXTENDED_PROFILE_PATH % [@district.id, nil]))
    lines.each do |line|
      # some CSV such as sql server appends a blank line and a rowcount
      next  if line[0] =~  /^-+|\(\d+ rows affected\)$/

      process_extended_profile_line line
    end

    @messages << "Successful import of #{File.basename(file_name)}"
  end

  def process_extended_profile_line line
    id_district = line[:id_district].to_i
    #    puts Student.find_by_id_district.inspect
    student_id = @students[id_district] #|| 'add_some_students_to_your_scenario'
    path = Student::EXTENDED_PROFILE_PATH  % [@district.id, student_id]
    return if student_id.blank?
    FileUtils.mkdir_p(File.dirname(path))
    #    File.open("#{path}", 'w+') {|f| f << line[:arbitrary]}
    File.open("#{path}", 'w') {|f| f << line[:arbitrary]}
  end

end
