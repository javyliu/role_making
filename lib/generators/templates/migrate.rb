class RoleMakingCreateRoles < ActiveRecord::Migration
  def change
    create_table(:roles) do |t|
      t.string :name
      t.string :display_name

      t.timestamps
    end

    create_table(:users_roles, :id => false) do |t|
      t.integer :user_id
      t.integer :role_id
    end

    add_index(:roles, :name)
    add_index(:users_roles, [ :user_id, :role_id ])
  end
end
