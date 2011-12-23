require 'fileutils'
class CreateInterventionPdfs
  def self.generate(district)
    InterventionDefinitionSummaryReport
      dir = "#{Rails.root}/public/system/district_generated_docs/#{district.id}/"
    old_files = Dir.glob("#{dir}*")
    new_files = []
    
    district.objective_definitions.each do |o| 
      FileUtils.mkdir_p dir unless File.exists? dir
      basefile = dir+"#{o.title.split(" ").join("_")}.".gsub("/","-").gsub("&","and")
      pdffile= "#{basefile}pdf"
      htmlfile = "#{basefile}html"
      group= InterventionDefinitionSummary.new(:objective_definition => o).to_grouping()

      File.open(pdffile,'w') do |f|o
        f << InterventionDefinitionSummaryReport.render_pdf(:objective_definition => o, :template => :standard, :group => group)
      end

      File.open(htmlfile,'w') do |f|
        f << InterventionDefinitionSummaryReport.render_html(:objective_definition => o, :template => :standard, :group => group)
      end

      new_files << pdffile
      new_files << htmlfile

      
    end
     FileUtils.rm(old_files - new_files)
     district.touch
  end

  def self.destroy(district)
      dir = "#{Rails.root}/public/system/district_generated_docs/#{district.id}/"
      FileUtils.rm_rf(dir) if File.exists?dir
  end
end
