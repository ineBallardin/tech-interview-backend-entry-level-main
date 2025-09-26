class AddAbandonedFieldsToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :abandoned, :boolean, default: false, null: false
    add_column :carts, :abandoned_at, :datetime
    add_column :carts, :last_interaction_at, :datetime
    
    add_index :carts, :abandoned
    add_index :carts, :abandoned_at
    add_index :carts, :last_interaction_at
    
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE carts 
          SET last_interaction_at = GREATEST(
            created_at,
            COALESCE((SELECT MAX(line_items.updated_at) 
                     FROM line_items 
                     WHERE line_items.cart_id = carts.id), created_at)
          )
        SQL
      end
    end
  end
end
