class Add1cId < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_products, :xchange_id, :bytea
    add_column :spree_variants, :xchange_id, :bytea
    add_column :spree_taxons, :xchange_id, :bytea
  end
end
