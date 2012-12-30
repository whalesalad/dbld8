module Concerns
  module FacebookInviteConcerns
    extend ActiveSupport::Concern

    def self.included(base)
      base.class_eval do
        after_create :hook_facebook_invites, :if => :relevant_facebook_invite
        
        # Facebook Invitations
        has_many :facebook_invites,
          :foreign_key => "user_id",
          :dependent => :destroy

        # The invites that might have led to my creation
        has_many :inverse_facebook_invites,
          :class_name => "FacebookInvite",
          :foreign_key => "facebook_id"
      end
    end

    def relevant_facebook_invite
      # This logic is split out because more than one invite might exist
      # and we'll want this to return just one single invite?
      inverse_facebook_invites.order('created_at DESC').first
    end

    def hook_facebook_invites
      # invite = relevant_facebook_invite
      # pseudocode
      #   1) Give the user who created this invite some credits
      # invite_user.credits += 10
      #   2) Create a friendship request between the creator <=> this new user.
      # invite_user.invite(self)
      #
      # This belongs as a background process most likely
      # Resque.enqueue(XXXFacebookInviteSucceeded, 'invite.id')
      #
    end

  end
end
