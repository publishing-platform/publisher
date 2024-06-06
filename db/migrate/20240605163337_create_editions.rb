class CreateEditions < ActiveRecord::Migration[7.1]
  def change
    create_table :editions do |t|
      t.string :title
      t.string :base_path
      t.text :summary
      t.json :contents, default: {}, null: false
      t.string :document_type_id, null: false
      t.string :state, null: false
      t.boolean :current, default: false, null: false
      t.datetime :published_at, precision: nil

      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :last_edited_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :document, null: false, foreign_key: { on_delete: :restrict }

      t.timestamps

      t.index :state
    end
  end
end
