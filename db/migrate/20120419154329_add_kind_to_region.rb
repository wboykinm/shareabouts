class AddKindToRegion < ActiveRecord::Migration
  def change
    add_column :regions, :kind, :string
    
    Region.find_each do |region|
      shapefile = region.shapefile
      region.update_attribute :kind, shapefile.kind if shapefile.respond_to? :kind
    end
  end
end
