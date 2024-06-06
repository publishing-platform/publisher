# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_06_05_163337) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "documents", force: :cascade do |t|
    t.uuid "content_id", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_documents_on_content_id", unique: true
    t.index ["created_by_id"], name: "index_documents_on_created_by_id"
  end

  create_table "editions", force: :cascade do |t|
    t.string "title"
    t.string "base_path"
    t.text "summary"
    t.json "contents", default: {}, null: false
    t.string "document_type_id", null: false
    t.string "state", null: false
    t.boolean "current", default: false, null: false
    t.datetime "published_at", precision: nil
    t.bigint "created_by_id", null: false
    t.bigint "last_edited_by_id", null: false
    t.bigint "document_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_editions_on_created_by_id"
    t.index ["document_id"], name: "index_editions_on_document_id"
    t.index ["last_edited_by_id"], name: "index_editions_on_last_edited_by_id"
    t.index ["state"], name: "index_editions_on_state"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.text "permissions"
    t.boolean "disabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "documents", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "editions", "documents", on_delete: :restrict
  add_foreign_key "editions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "editions", "users", column: "last_edited_by_id", on_delete: :restrict
end
