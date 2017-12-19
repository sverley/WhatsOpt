require 'whats_opt/discipline'
require 'whats_opt/excel_mda_importer'
require 'whats_opt/cmdows_mda_importer'
require 'whats_opt/openmdao_mapping'

class MultiDisciplinaryAnalysis < ApplicationRecord

  include WhatsOpt::OpenmdaoModule

  resourcify
    
  has_one :attachment, :as => :container, :dependent => :destroy
  accepts_nested_attributes_for :attachment, allow_destroy: true
  validates_associated :attachment
  
  has_many :disciplines, :dependent => :destroy
  accepts_nested_attributes_for :disciplines, 
    reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true
      
  before_validation(on: :create) do
    _create_from_attachment if attachment_exists
  end
  validate :check_mda_import_error, on: :create, if: :attachment_exists
  validates :name, presence: true
    
  def driver
    self.disciplines.driver&.first
  end
  
  def design_variables
    return self.driver.output_variables if driver
    []
  end

  def optimization_variables
    return self.driver.input_variables if driver
    []
  end  
  
  def objective_variables
    return self.driver.input_variables.objectives if driver
    []
  end

  def constraint_variables
    self.driver.input_variables.constraints if driver
    []
  end
  
  def to_xdsm_json
    { 
      id: self.id,
      name: self.name,
      nodes: build_nodes,
      edges: build_edges,
      workflow: [],
      vars: build_var_tree
    }.to_json
    end

  def build_nodes
    return self.disciplines.analyses.map {|d| 
      t = case d.name.downcase 
          when /function/
            "function"
          when /optimizer/
            "optimization"
          else
            "analysis"
          end 
      { id: "#{d.id}", type:t , name: d.name } 
    }
  end

  def build_edges
    edges = []
    @all_connections = Set.new

    # connections
    disciplines.each do |d_from|
      outputs = d_from.output_variables 
      disciplines.each do |d_to|
        next if d_to == d_from
        inputs = d_to.input_variables
        connections = outputs.map(&:name) & inputs.map(&:name)
        @all_connections.merge(connections)
        unless connections.empty?
          frid = (d_from.name == WhatsOpt::Discipline::DRIVER_NAME)?"_U_":d_from.id 
          toid = (d_to.name == WhatsOpt::Discipline::DRIVER_NAME)?"_U_":d_to.id
          edges << { from: "#{frid}", to: "#{toid}", name: connections.join(",") }
        end
      end
    end

    # pendings
    disciplines.each do |d|
      in_pendings = _get_pending_connections(d.input_variables)
      unless in_pendings.empty?
        edges << { from: "_U_", to: "#{d.id}", name: in_pendings.join(",") }
      end

      out_pendings = _get_pending_connections(d.output_variables)
      unless out_pendings.empty?
        edges << { from: "#{d.id}", to: "_U_", name: out_pendings.join(",") }
      end        
    end   
    edges
  end

  def build_var_tree
    res = disciplines.analyses.map {|d| {d.name => {in: d.input_variables, out: d.output_variables}}}
    res.inject({}) {|result, h| result.update(h)}
  end
  
  def owner
    owners = User.with_role(:owner, self)
    owners.first.login if owners
  end
  
  private
  
    def _get_pending_connections(vars)
      pendings = []
      vars.each do |v|
        unless @all_connections.include?(v.name)
          pendings << v.name
        end
      end
      pendings
    end      
    
    def attachment_exists
      self.attachment && self.attachment.exists?
    end
    
    def check_mda_import_error
      begin
        if self.attachment.mda_excel?
          importer = WhatsOpt::ExcelMdaImporter.new(self.attachment.path)
        elsif self.attachment.mda_cmdows?
          mda_name = File.basename(self.attachment.original_filename, '.cmdows').camelcase
          importer = WhatsOpt::CmdowsMdaImporter.new(self.attachment.path, mda_name)
        else
          self.errors.add("Bad file format")
        end
      rescue
        self.errors.add("Import error")
      end
    end
    
    def _create_from_attachment
      begin
        if self.attachment.exists?
          if self.attachment.mda_excel?
            self.name = File.basename(self.attachment.original_filename, '.xlsx').camelcase
            importer = WhatsOpt::ExcelMdaImporter.new(self.attachment.path)
          elsif self.attachment.mda_cmdows?
            self.name = File.basename(self.attachment.original_filename, '.cmdows').camelcase
            importer = WhatsOpt::CmdowsMdaImporter.new(self.attachment.path, self.name)
          else
            raise WhatsOpt::MdaImporter::MdaImportError.new("bad format, can not be imported as an MDA")
          end
          self.name = importer.get_mda_attributes[:name]
          vars = importer.get_variables_attributes
          importer.get_disciplines_attributes().each do |dattr|
            id = dattr[:id]
            dattr.delete(:id)
            disc = self.disciplines.build(dattr)
            disc.variables.build(vars[id]) if vars[id]
          end
        else
          raise WhatsOpt::MdaImporter::MdaImportError.new("does not exist")
        end
      rescue WhatsOpt::MdaImporter::MdaImportError => e
        self.errors.add(:attachment, e.message)
      end
    end

end

