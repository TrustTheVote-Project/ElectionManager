class Ability
  
  include CanCan::Ability
  
  def initialize(user)
    
    unless user
      user =  User.new
      user.roles << UserRole.new(:name => 'public')
    end

    if user.role?(:root)
       can :manage, :all
     elsif user.role?(:standard)
      can [:manage], [Election]
      # can [:read, :create, :update, :destroy], [Election]
      # can [:index], [Election]
    elsif user.role?(:public)
      can :read, [Election]
      can [:register, :registration_create], [User]
    end
  end
end
