module Features
  module FormHelpers
    def submit_form
      find('input[name="commit"]').click
    end
  end
end
