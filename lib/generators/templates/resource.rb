class Resource
  include RoleMaking::Resourcing

  #group :user do
  #  resource [:read,:update,:destroy], User do |admin,user|
  #    admin != user
  #  end

  #  resource :create,User

  #end

  #group :post do
  #  resource :read,Post
  #  resource [:update,:destroy,:create],Post
  #end

  ##with hashs
  #group :post do
  #  resource :read,Post
  #  resource [:update,:destroy,:create],Post,con: {user_id: 'user.leader_data'}
  #end
end
