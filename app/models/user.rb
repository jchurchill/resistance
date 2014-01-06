class User < ActiveRecord::Base
	acts_as_authentic do |c|
		# optional config block
		c.login_field = :login
  end
end
