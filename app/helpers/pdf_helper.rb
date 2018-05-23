module PdfHelper
    def asset_pathname(pathname)
      # if pathname =~ URI_REGEXP
      #     pathname
      #   else
          "#{File.join(Rails.root, 'public', pathname)}"
        # end
    end
end
