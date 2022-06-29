# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_06_29_054123) do

  create_table "active_admin_comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "namespace"
    t.text "body", limit: 16777215
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

  create_table "admin_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
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

  create_table "articles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "content", limit: 16777215
    t.bigint "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "era"
    t.boolean "pinned"
    t.integer "category"
    t.boolean "public"
    t.index ["category", "pinned", "era"], name: "index_articles_on_category_and_pinned_and_era"
  end

  create_table "attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "article_id"
    t.string "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["article_id"], name: "index_attachments_on_article_id"
  end

  create_table "ban_compilers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "contest_id"
    t.bigint "compiler_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["compiler_id"], name: "fk_rails_6b2cbab705"
    t.index ["contest_id", "compiler_id"], name: "index_ban_compilers_on_contest_id_and_compiler_id", unique: true
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "content", limit: 16777215
    t.bigint "user_id"
    t.bigint "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "compilers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "format_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contest_problem_joints", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "contest_id"
    t.bigint "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contest_id", "problem_id"], name: "contest_task_ix", unique: true
  end

  create_table "contests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "description", limit: 16777215
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "contest_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cd_time", default: 15, null: false
    t.boolean "disable_discussion", default: true, null: false
    t.integer "freeze_time", null: false
    t.boolean "show_detail_result", default: true, null: false
    t.index ["start_time", "end_time"], name: "index_contests_on_start_time_and_end_time"
  end

  create_table "judge_servers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "ip"
    t.string "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "limits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "time", default: 1000
    t.integer "memory", default: 65536
    t.integer "output", default: 65536
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "testdatum_id"
    t.index ["testdatum_id"], name: "index_limits_on_testdatum_id"
  end

  create_table "posts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "content", limit: 16777215
    t.bigint "user_id"
    t.bigint "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "contest_id"
    t.boolean "global_visible", default: true, null: false
    t.index ["contest_id"], name: "index_posts_on_contest_id"
    t.index ["updated_at"], name: "index_posts_on_updated_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "problems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description", limit: 16777215
    t.text "source", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "input", limit: 16777215
    t.text "output", limit: 16777215
    t.text "example_input", limit: 16777215
    t.text "example_output", limit: 16777215
    t.text "hint", limit: 16777215
    t.integer "visible_state", default: 0
    t.text "sjcode", limit: 4294967295
    t.text "interlib", limit: 4294967295
    t.integer "old_pid"
    t.integer "specjudge_type", null: false
    t.integer "interlib_type", null: false
    t.bigint "specjudge_compiler_id"
    t.index ["name"], name: "index_problems_on_name"
    t.index ["specjudge_compiler_id"], name: "index_problems_on_specjudge_compiler_id"
    t.index ["visible_state"], name: "index_problems_on_visible_state"
  end

  create_table "submission_tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "submission_id"
    t.integer "position"
    t.string "result"
    t.integer "time"
    t.integer "memory"
    t.decimal "score", precision: 18, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id", "position"], name: "index_submission_tasks_on_submission_id_and_position", unique: true
    t.index ["submission_id"], name: "index_submission_tasks_on_submission_id"
  end

  create_table "submissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "code", limit: 4294967295
    t.string "result", default: "queued"
    t.decimal "score", precision: 18, scale: 6, default: "0.0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "problem_id", default: 0
    t.bigint "user_id", default: 0
    t.bigint "contest_id"
    t.integer "total_time"
    t.integer "total_memory"
    t.text "message", limit: 16777215
    t.bigint "compiler_id", default: 1, null: false
    t.index ["compiler_id"], name: "fk_rails_55e5b9f361"
    t.index ["contest_id"], name: "index_submissions_on_contest_id"
    t.index ["problem_id"], name: "index_submissions_on_problem_id"
    t.index ["result"], name: "index_submissions_on_result"
    t.index ["total_time", "total_memory"], name: "submissions_sort_ix"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "taggings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
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

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "testdata", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "problem_id"
    t.string "test_input"
    t.string "test_output"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
  end

  create_table "testdata_sets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "problem_id"
    t.decimal "score", precision: 18, scale: 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "td_list", null: false
    t.text "constraints", limit: 16777215
    t.index ["problem_id"], name: "index_testdata_sets_on_problem_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
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
    t.string "nickname"
    t.string "avatar"
    t.boolean "admin", default: false
    t.string "username"
    t.string "motto"
    t.string "school"
    t.integer "gradyear"
    t.string "name"
    t.datetime "last_submit_time"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "ban_compilers", "compilers"
  add_foreign_key "ban_compilers", "contests"
  add_foreign_key "posts", "contests"
  add_foreign_key "problems", "compilers", column: "specjudge_compiler_id"
  add_foreign_key "submissions", "compilers"
end
