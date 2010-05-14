class Ability
  
  include CanCan::Ability
  
  def initialize(user)
    unless user
      user =  User.new
      user.roles << UserRole.new(:name => 'public')
    end
    
     if user.role? :root 
       can :manage, :all
     else
       can :read, :all
     end
    
  end
end
