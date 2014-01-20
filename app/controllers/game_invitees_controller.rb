class GameInviteesController < ApplicationController

	def create
		@invitee = GameInvitee.new(invitee_params)
		saved = @invitee.save
		if saved
			redirect_to game_url(invitee_params[:game_id])
		else
			# todo figure out better structure for this
			redirect_to game_url(invitee_params[:game_id])
		end
	end

	private
		def invitee_params
			params.require(:game_invitee)
				.permit(:game_id, :user_id)
		end
end
