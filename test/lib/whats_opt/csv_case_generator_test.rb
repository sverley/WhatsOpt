require 'test_helper'
require 'whats_opt/csv_case_generator'

class CsvCaseGeneratorTest < ActiveSupport::TestCase

  def setup
    @ope = operations(:doe)
  end
  
  test "should generate csv file from given operation cases" do
    zippath = Tempfile.new('cases.zip')
    File.open(zippath, 'w') do |f|
      @csvgen = WhatsOpt::CsvCaseGenerator.new
      content, _ = @csvgen.generate @ope.cases
      f.write content
    end
    
    Zip::File.open(zippath) do |zip|
      zip.each do |entry|
        assert_equal "x1,obj\n1,4\n2,5\n3,6\n", entry.get_input_stream.read
      end
    end
  end
  
end 