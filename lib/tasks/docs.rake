namespace :docs do
  desc "TODO"
  task generate_state_machine_diagram: :environment do
    require 'erb'
    output_file = Rails.root.join('docs', 'state_machine_generated.mmd')
    template_file = Rails.root.join('docs', 'state_machine.mmd.erb')
    @states = BookingStateMachine.states
    @transitions = BookingStateMachine.successors

    File.open(output_file, 'w') do |file|
      file.write(ERB.new(File.read(template_file), nil, '>').result(binding))
    end
    `mmdc -i #{output_file} -o #{output_file}.svg -t forest`
  end

end
