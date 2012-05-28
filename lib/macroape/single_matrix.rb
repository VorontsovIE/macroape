module PWM
  class SingleMatrix
    attr_reader :matrix
    attr_accessor :name
    def initialize(matrix)
      @matrix = matrix
    end
    include MatrixTransformations, MatrixInformation
    
    def self.build_matrix(lines, name = nil)
      pwm_name = name
      begin
        lines.first.split.each{|x| Float(x) }
        start_line = 0
      rescue
        start_line = 1
        pwm_name = lines.first.chomp.match(/(?:>\s)?(.*)$/)[1]
      end
      
      if lines[start_line].split.length == 4
        pwm = SingleMatrix.new(lines[start_line..-1].map{|str| str.split.map(&:to_f)})
      else
        pwm = SingleMatrix.new(lines[start_line..-1].map{|str| str.split.map(&:to_f)}.transpose)
      end
      raise "PWM::SingleMatrix.build_matrix can't create matrix using this input" unless pwm.matrix.all?{|l| l.length == 4}
      pwm.name = pwm_name
      pwm
    end
    
    def self.load_from_stdin(input_stream, name = nil)
      build_matrix(input_stream.readlines, name)
    end
    def self.load_from_line_array(lines, name = nil)
      build_matrix(lines, name)
    end
    
    def self.load_pat(filename)
      build_matrix( File.open(filename,'r'){|f| f.readlines}, File.basename_wo_ext(filename))
    end
    
    def with_background(background)
      type_cast(MatrixOnBackground){@probabilities = background}.depth_dup
    end
  end
end