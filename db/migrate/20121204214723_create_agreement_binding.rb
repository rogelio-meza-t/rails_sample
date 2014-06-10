class CreateAgreementBinding < ActiveRecord::Migration
  def change
    create_table :agreement_bindings do |t|
      t.references :sales_channel_agreement, :tour_operator
      t.timestamps
    end
  end
end
