---- Roleplay: Prison

hook.Add("PlayerButtonDown", "ShowAnimationsBind", function(InPlayer, InButton)

	if InButton == KEY_F1 and CurTime() - (InPlayer.ShowAnimationsBindLastSend or 0.0) > 0.0 then

		InPlayer:SendLua("ShowAnimations()")

		InPlayer.ShowAnimationsBindLastSend = CurTime()
	end
end)

function ServerReceiveDoAnimation(InMessageLength, InPlayer)

	if UtilPlayerCanInteract(InPlayer) then

		local SampleAnimation = net.ReadInt(32)

		ServerSendMulticastDoAnimation(InPlayer, SampleAnimation, true)
	end
end

function ServerSendMulticastDoAnimation(InPlayer, InAnimation, bAutoKill)

	net.Start("MulticastDoAnimation")

	net.WriteInt(InAnimation, 32)

	net.WriteInt(InPlayer:EntIndex(), 32)

	net.WriteBool(bAutoKill)

	MsgN(Format("%s %i", InPlayer, InAnimation))

	net.Broadcast()
end
