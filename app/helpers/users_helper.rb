module UsersHelper
  def setup_user_roles(roles)
    returning(roles) do
      UserRole.display_names.each do |name|
        roles.build(:name => name) unless roles.find_by_name(name)
      end
    end
  end
  # TODO: may want to move this into the application_helper if we need
  # checkboxes other than for user roles.
  def checkbox_options(builder)
    cb_options = {:class => 'check_box'}
    cb_options.merge!(:checked => false) if builder.object.new_record?
    cb_options
  end
end
