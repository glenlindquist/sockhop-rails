class Channel < ApplicationRecord
  authenticates_with_sorcery!
  # == Constants ============================================================
  
  # == Attributes ===========================================================
  
  # == Extensions ===========================================================
  
  # == Relationships ========================================================
  
  # == Validations ==========================================================
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :name, uniqueness: true
  # == Scopes ===============================================================
  
  # == Callbacks ============================================================
  after_create :init_redis
  after_destroy :clear_redis
  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================
  
  # == Private Instance Methods =============================================
  private
    def init_redis
      #TODO
    end

    def clear_redis
      #TODO
    end
end
