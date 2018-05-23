module PdfHelper
  def embed_remote_image(url, content_type)
    require 'open-uri'
    asset = open(url, "r:UTF-8") { |f| f.read }
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{content_type};base64,#{Rack::Utils.escape(base64)}"
  end
  def asset_pathname(pathname)
    # if pathname =~ URI_REGEXP
    #     pathname
    #   else
        "#{File.join(Rails.root, 'public', pathname)}"
      # end
  end
end
