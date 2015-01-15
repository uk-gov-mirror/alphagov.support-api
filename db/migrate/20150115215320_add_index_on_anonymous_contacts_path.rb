class AddIndexOnAnonymousContactsPath < ActiveRecord::Migration
  def change
    add_index "anonymous_contacts", ["path"], name: "index_anonymous_contacts_on_path", using: :btree
  end
end
