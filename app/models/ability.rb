class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    case user.role
    when 'dispatcher'
      can [:read, :update, :delete], Ticket
    when 'driver'
      can [:update, :delete], Ticket, driver_id: user.id
      can :read, Ticket
      can :take, Ticket do |ticket|
        ticket.suggested? and
        ticket.suggestions.any? { |s| s.user_id == user.id } and
        !ticket.suggestions.where("user_id = ?", user.id).all?(&:rejected?)
      end
      can :start, Ticket do |ticket|
        ticket.driver_id == user.id and
        ticket.state == "taken" and
        ticket.driver.tickets.with_state(:started).empty?
      end
      can :finish, Ticket, state: "started", driver_id: user.id
      if !user.current_ticket
        can :take_a_brake
      end
    when 'admin'
      can :manage, :all
    end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
