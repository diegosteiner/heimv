module PdfHelper
  def asset_pathname(pathname)
    # if pathname =~ URI_REGEXP
    #     pathname
    #   else
    Rails.root.join('public', pathname).to_s
    # end
  end
end
