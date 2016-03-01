class User < ActiveRecord::Base
  has_many :sites

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :confirmable, :lockable

  def to_s
    self.full_name
  end

  def full_name
    [self.first_name, self.last_name].compact.map {|p| p.strip}.join(" ").strip
  end

  protected

    # if confirmation is not required, the users will be able
    # to confirm their email address, but never required to
    def confirmation_required?
      false
    end
end
