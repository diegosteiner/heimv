module Features
  module FormHelpers
    def submit_form
      find('input[name="commit"]').click
    end

    def find_resource_in_table(resource)
      find("tr[data-id='#{resource&.to_param || resource}']")
    end
  end
end
