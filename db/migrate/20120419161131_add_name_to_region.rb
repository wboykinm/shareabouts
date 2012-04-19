class AddNameToRegion < ActiveRecord::Migration
  def change
    add_column :regions, :name, :string
    
    Region.find_each do |region|
      shapefile = region.shapefile
      region.update_attribute( :name, region.metadata[shapefile.name_field] ) if shapefile.respond_to? :name_field
    end
  end
end