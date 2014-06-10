class AddStartTimeToProductSchedule < ActiveRecord::Migration
  def change
  	# after executing this migration you must run the following command in the rails console
  	#
  	# Product.all.each do |product|
  	# 	product.product_schedules.update_all({start_time: product.start_time})
  	# end
  	#
  	# with this command you can populate the new columns and stop using pthe start_time from
  	# the product itself.

  	add_column :product_schedules, :start_time, :time
  end
end
