module CSVImporter
	class CSVImporterError < StandardError; end
	class SkywardExtraneousFile < CSVImporterError; end
end