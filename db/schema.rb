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

ActiveRecord::Schema[7.0].define(version: 2023_06_02_023419) do
  create_table "active_admin_comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "namespace"
    t.text "body", size: :medium
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.bigint "author_id"
    t.string "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "username"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_admin_users_on_username", unique: true
  end

  create_table "announcements", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "contest_id"
    t.index ["contest_id"], name: "index_announcements_on_contest_id"
  end

  create_table "articles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.text "content", size: :medium
    t.bigint "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "era"
    t.boolean "pinned"
    t.integer "category"
    t.boolean "public"
    t.index ["category", "pinned", "era"], name: "index_articles_on_category_and_pinned_and_era"
  end

  create_table "attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "article_id"
    t.string "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["article_id"], name: "index_attachments_on_article_id"
  end

  create_table "ban_compilers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "compiler_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "with_compiler_type"
    t.bigint "with_compiler_id"
    t.index ["compiler_id"], name: "fk_rails_6b2cbab705"
    t.index ["with_compiler_type", "with_compiler_id", "compiler_id"], name: "index_ban_compiler_unique", unique: true
    t.index ["with_compiler_type", "with_compiler_id"], name: "index_ban_compilers_on_with_compiler_type_and_with_compiler_id"
  end

  create_table "code_contents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.binary "code", size: :long
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.text "content", size: :medium
    t.bigint "user_id"
    t.bigint "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "user_visible", default: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "compilers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "format_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.string "extension"
    t.index ["name"], name: "index_compilers_on_name", unique: true
  end

  create_table "contest_problem_joints", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "contest_id"
    t.bigint "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contest_id", "problem_id"], name: "contest_task_ix", unique: true
  end

  create_table "contest_registrations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "contest_id", null: false
    t.boolean "approved", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contest_id", "approved"], name: "index_contest_registrations_on_contest_id_and_approved"
    t.index ["contest_id", "user_id"], name: "index_contest_registrations_on_contest_id_and_user_id", unique: true
    t.index ["user_id", "approved"], name: "index_contest_registrations_on_user_id_and_approved"
  end

  create_table "contests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.text "description", size: :medium
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "contest_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cd_time", default: 15, null: false
    t.boolean "disable_discussion", default: true, null: false
    t.integer "freeze_minutes", default: 0, null: false
    t.boolean "show_detail_result", default: true, null: false
    t.boolean "hide_old_submission", default: false, null: false
    t.text "user_whitelist"
    t.boolean "skip_group", default: false
    t.text "description_before_contest", size: :medium
    t.boolean "dashboard_during_contest", default: true
    t.integer "register_mode", default: 0, null: false
    t.datetime "register_before", null: false
    t.index ["start_time", "end_time"], name: "index_contests_on_start_time_and_end_time"
  end

  create_table "judge_servers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "ip"
    t.string "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "online", default: false
  end

  create_table "old_submission_testdata_results", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "old_submission_id"
    t.integer "position"
    t.string "result"
    t.decimal "score", precision: 18, scale: 6
    t.integer "time"
    t.integer "rss"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["old_submission_id"], name: "index_old_submission_testdata_results_on_old_submission_id"
  end

  create_table "old_submissions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "submission_id"
    t.bigint "problem_id"
    t.string "result"
    t.decimal "score", precision: 18, scale: 6
    t.integer "total_time"
    t.integer "total_memory"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id", "result", "score", "total_time", "total_memory"], name: "index_old_submissions_topcoder", order: { score: :desc }
    t.index ["problem_id", "result"], name: "index_old_submissions_on_problem_id_and_result"
    t.index ["problem_id"], name: "index_old_submissions_on_problem_id"
    t.index ["submission_id"], name: "index_old_submissions_on_submission_id", unique: true
  end

  create_table "posts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.text "content", size: :medium
    t.bigint "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "global_visible", default: true, null: false
    t.string "postable_type"
    t.bigint "postable_id"
    t.integer "post_type", default: 0
    t.boolean "user_visible", default: false
    t.index ["postable_type", "post_type"], name: "index_post_post_type"
    t.index ["postable_type", "postable_id"], name: "index_post_postable"
    t.index ["postable_type", "postable_id"], name: "index_posts_on_postable"
    t.index ["updated_at"], name: "index_posts_on_updated_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "problems", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.text "description", size: :medium
    t.text "source", size: :medium
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "input", size: :medium
    t.text "output", size: :medium
    t.text "hint", size: :medium
    t.integer "visible_state", default: 0
    t.text "sjcode", size: :long
    t.text "interlib", size: :long
    t.integer "specjudge_type", null: false
    t.integer "interlib_type", null: false
    t.bigint "specjudge_compiler_id"
    t.integer "discussion_visibility", default: 2
    t.text "interlib_impl", size: :long
    t.integer "score_precision", default: 2
    t.string "verdict_ignore_td_list", null: false
    t.integer "num_stages", default: 1
    t.boolean "judge_between_stages", default: false
    t.string "default_scoring_args"
    t.boolean "strict_mode", default: false
    t.boolean "skip_group", default: false
    t.boolean "ranklist_display_score", default: false
    t.integer "code_length_limit", default: 5000000
    t.index ["name"], name: "index_problems_on_name"
    t.index ["specjudge_compiler_id"], name: "index_problems_on_specjudge_compiler_id"
    t.index ["visible_state"], name: "index_problems_on_visible_state"
  end

  create_table "sample_testdata", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "problem_id"
    t.text "input", size: :medium
    t.text "output", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id"], name: "index_sample_testdata_on_problem_id"
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "submission_subtask_results", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.binary "result", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_submission_subtask_results_on_submission_id", unique: true
  end

  create_table "submission_testdata_results", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "submission_id"
    t.integer "position"
    t.string "result"
    t.decimal "time", precision: 12, scale: 3
    t.integer "rss"
    t.decimal "score", precision: 18, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vss"
    t.string "message_type"
    t.text "message", size: :medium
    t.index ["submission_id", "position"], name: "index_submission_testdata_results_on_submission_id_and_position", unique: true
    t.index ["submission_id"], name: "index_submission_testdata_results_on_submission_id"
  end

  create_table "submissions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "result", default: "queued"
    t.decimal "score", precision: 18, scale: 6, default: "0.0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "problem_id", default: 0
    t.bigint "user_id", default: 0
    t.bigint "contest_id"
    t.integer "total_time"
    t.integer "total_memory"
    t.text "message", size: :medium
    t.bigint "compiler_id", null: false
    t.bigint "code_length", default: 0, null: false
    t.bigint "code_content_id", null: false
    t.index ["code_content_id"], name: "index_submissions_on_code_content_id"
    t.index ["compiler_id"], name: "fk_rails_55e5b9f361"
    t.index ["contest_id", "compiler_id", "id"], name: "index_submissions_contest_compiler", order: { id: :desc }
    t.index ["contest_id", "problem_id", "result", "score", "total_time", "total_memory"], name: "index_submissions_topcoder", order: { score: :desc }
    t.index ["contest_id", "problem_id", "user_id", "result"], name: "index_submissions_problem_query"
    t.index ["contest_id", "result", "id"], name: "index_submissions_contest_result", order: { id: :desc }
    t.index ["contest_id", "user_id", "problem_id", "result"], name: "index_submissions_user_query"
    t.index ["contest_id"], name: "index_submissions_on_contest_id"
    t.index ["result", "contest_id", "id"], name: "index_submissions_fetch"
    t.index ["result", "updated_at"], name: "index_submissions_on_result_and_updated_at"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "subtasks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "problem_id"
    t.decimal "score", precision: 18, scale: 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "td_list", null: false
    t.text "constraints", size: :medium
    t.index ["problem_id"], name: "index_subtasks_on_problem_id"
  end

  create_table "taggings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "tag_id"
    t.bigint "taggable_id"
    t.string "taggable_type"
    t.bigint "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "testdata", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "problem_id"
    t.string "test_input"
    t.string "test_output"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
    t.integer "time_limit", default: 1000
    t.integer "vss_limit", default: 65536
    t.integer "rss_limit"
    t.integer "output_limit", default: 65536
    t.boolean "input_compressed", default: false
    t.boolean "output_compressed", default: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "nickname"
    t.string "avatar"
    t.boolean "admin", default: false
    t.string "username"
    t.string "motto"
    t.string "school"
    t.integer "gradyear"
    t.string "name"
    t.datetime "last_submit_time"
    t.bigint "last_compiler_id"
    t.string "type", default: "User", null: false
    t.bigint "contest_id"
    t.index ["contest_id"], name: "index_users_on_contest_id"
    t.index ["last_compiler_id"], name: "index_users_on_last_compiler_id"
    t.index ["type", "email"], name: "index_users_on_type_and_email", unique: true
    t.index ["type", "nickname"], name: "index_users_on_type_and_nickname", unique: true
    t.index ["type", "reset_password_token"], name: "index_users_on_type_and_reset_password_token", unique: true
    t.index ["type", "username"], name: "index_users_on_type_and_username"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "announcements", "contests"
  add_foreign_key "ban_compilers", "compilers"
  add_foreign_key "problems", "compilers", column: "specjudge_compiler_id"
  add_foreign_key "submission_subtask_results", "submissions"
  add_foreign_key "submissions", "code_contents"
  add_foreign_key "submissions", "compilers"
  add_foreign_key "users", "compilers", column: "last_compiler_id"
  add_foreign_key "users", "contests"
end
