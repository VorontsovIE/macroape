# r_stream, w_stream - supposed to be a pipe. Data's read from r_stream, pwm's extracted, remaining data pushed back to w_stream
#  ... --> w_stream --> r_stream --> data
#              ^                       |
#              |                       v
#             ...  <--  w_stream  <-- ... --> extracted pwm
def extract_pwm(r_stream, w_stream)
  lines = r_stream.readlines
  return [r_stream, w_stream, nil] if lines.empty?
  
  extracted_pwm = [lines.shift]
  while extracted_pwm.last.chomp == ''
    extracted_pwm = [lines.shift.strip]
    return [r_stream, w_stream, nil] unless extracted_pwm.last
  end
  
  r_stream.close
  begin
    until lines.empty? 
      line = lines.shift
      line.split.each{|x| Float(x) } # raises error if string is not a numeric
      raise 'Not a PWM string (too little number of numbers - may be empty string or name of next pwm). PWM finished' if line.split.size < 4
      extracted_pwm << line
    end
  rescue
    lines.unshift(line)
  end
  new_r_stream, new_w_stream = IO.pipe
  lines.each{|one_line| new_w_stream.write(one_line)}
  new_w_stream.close
  
  [new_r_stream, new_w_stream, extracted_pwm]
end