---- Roleplay: Prison

hook.Add("PlayerButtonDown", "ShowAnimationsBind", function(InPlayer, InButton)

	if InButton == KEY_F1 and CurTime() - (InPlayer.ShowAnimationsBindLastSend or 0.0) > 0.0 then

		InPlayer:SendLua("ShowAnimations()")

		InPlayer.ShowAnimationsBindLastSend = CurTime()
	end
end)

function ServerReceiveDoAnimation(InMessageLength, InPlayer)

	if UtilPlayerCanDoAnimation(InPlayer) then

		local Gesture = net.ReadInt(32)

		net.Start("MulticastDoAnimation")

		net.WriteInt(Gesture, 32)

		net.WriteInt(InPlayer:EntIndex(), 32)

		MsgN(Format("%s %i", InPlayer, Gesture))

		net.Broadcast()
	end
end