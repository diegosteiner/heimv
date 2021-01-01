class RenameFilterParamsToPrefilterParams < ActiveRecord::Migration[6.0]
  def change
    rename_column :data_digests, :filter_params, :prefilter_params
  end
end
