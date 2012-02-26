class TeamNotesReport < DefaultReport
  stage :header, :body
  required_option :user, :school, :start_date, :end_date
  load_html_csv_text

  def setup
    self.data = TeamNotes.new(formatter.format,options)
  end

  class PDF < Ruport::Formatter::PDF
    renders :pdf, :for => TeamNotesReport

    build :header do
      add_text "Report Generated at #{Time.now.to_s(:long)}"
    end

    build :body do
      pdf_writer.start_page_numbering(350,10,8,:center,"Page: <PAGENUM>")

      output << render_grouping(data.to_grouping, options.to_hash.merge(:formatter=> pdf_writer))
    end
  end

  # # I was considering going this route if I had to support links in HTML only...
  # class HTML < Ruport::Formatter::HTML
  #   renders :html, :for => TeamNotesReport
  #
  #   output << render_grouping(data.to_grouping, options.to_hash.merge(:formatter => html_writer))
  # end
end


class TeamNotes

  def initialize(format,options={})
    @user = options[:user]
    @school = options[:school]
    @start_date = options[:start_date]
    @end_date = options[:end_date]
    @sort_field = options[:sort_field] || 'Student'
    @content = options[:content].to_s
    @format = format.to_s
  end

  def to_table
    return unless defined? Ruport

    # rt = @user.student_comments.report_table(:all, :only => [:body])
    student_ids = Enrollment.search({:search_type =>'list_all',
                 :school_id => @school.id, :user => @user}).collect(&:student_id)


    rt = StudentComment.report_table(:all,
      :conditions => {:created_at  => @start_date.beginning_of_day..@end_date.end_of_day,
                    :students => {:id=> student_ids,:district_id => @user.district_id }}, # OK to remove, since handled by search above?
      :include => {:student => {:only => [:id], :methods => :fullname}, :user => {:only => [], :methods => :fullname}},
      :joins => :student,
      :only => [:body, :created_at],
      :filters => lambda{|r| r["body"].include?(@content)})

    unless rt.empty?
      rt.replace_column('created_at', 'Date') do |r|
        r['created_at'].to_date.to_s(:report)
      end

      rt.replace_column('student.fullname', 'Student') do |r|
        if @format == "html"
          "<a href=\"/students/#{r['student.id']}\">#{r['student.fullname']}</a>"
        elsif @format == "pdf"
          "<c:alink uri=\"https://www.simspilot.org/students/#{r['student.id']}\">#{r['student.fullname']}</c:alink>"
        else
          r['student.fullname']
        end
      end
    end

    return rt if rt.column_names.blank?

    rt.rename_columns('body' => 'Team Note', 'user.fullname' => 'User Name')

    rt.reorder('Student', 'Date', 'User Name', 'Team Note')
      rt
  end

  def to_grouping
    @table ||= to_table
    return @table if  @table.column_names.blank?
    if @sort_field == 'Student'
      Ruport::Data::Grouping(@table, :by => 'Student')
    else
      @table.sort_rows_by(@sort_field)
    end
  end
end
