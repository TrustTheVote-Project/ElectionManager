class Asset < ActiveRecord::Base
#  attr_accessor :asset_file_name, :display_name, :asset_updated_at, :asset_content_type
  has_attached_file :asset, {:styles => { :medium => "300x300>", :thumb => "100x100>" }}

# Make sure that ident is not nil. If it is, create a unique one.
  def before_validation
    if self.blank? || self.ident.blank?
      self.ident = "asset-#{ActiveSupport::SecureRandom.hex}"
      self.save!
    end
  end
end
