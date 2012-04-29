module CSVImporter
  class SchoolAdmins < CSVImporter::BaseRoles
    FIELD_DESCRIPTIONS = {
      :district_user_id =>"Key for user"
    }
    class << self
      def csv_headers
        [:district_user_id]
      end
      def description
        "School admins, role.  You also need to assign them as an admin to a specific school (edit their user within SIMS)  It is recommended that you use the admins_of_schools.csv instead."
      end

      def overwritten
      end

      def load_order
      end

      def removed
      end

#      def related
#      end

      def how_often
        "Start of school year, or handle manually."
      end

#      def alternate
#      end

      def upload_responses
        super
      end

      def how_many_rows
        "One row per user with this access."
      end
    end


  end
end

