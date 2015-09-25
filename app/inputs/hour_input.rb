class HourInput < SimpleForm::Inputs::Base
  def input
    @builder.select(attribute_name, hour_options, { :selected => selected_value }, { :class => "select required form-control" })
  end

  private

  def hour_options
    hour = []
    time = DateTime.now
    (7..21).each do |h|
      %w(00 30).each do |m|
        # hour.push ["#{h}:#{m}", "#{"%02d" % h}:#{m}:00"]
        new_time = time.change({ hour: h.to_i, min: m.to_i })
        hour.push ["#{h}:#{m}", new_time.strftime('%Y-%m-%d %H:%M:%S')]
      end
    end
    hour[0..-2]
  end

  def selected_value
    value = object.send(attribute_name)
    value && value.strftime("%H:%M:%S")
  end
end