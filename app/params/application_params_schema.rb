class ApplicationParamsSchema < Dry::Schema::Params
  def permit(params)
    call(params.try(:to_unsafe_hash) || params).to_h
  end
end
