# Send invitations to new and existing users.
class InviteMailer < ActionMailer::Base
  def existing_user(invite, message: nil, subject: nil, cc: [])
    @invite = invite
    @message = message
    mail(
      from:    Invitation.configuration.mailer_sender,
      to:      @invite.email,
      subject: custom_subject(subject, existing_user: true),
      cc:      cc
    )
  end

  def new_user(invite, message: nil, subject: nil, cc: [])
    @invite = invite
    @user_registration_url = Invitation.configuration.user_registration_url.call(invite_token: @invite.token)
    @message = message
    mail(
      from:    Invitation.configuration.mailer_sender,
      to:      @invite.email,
      subject: custom_subject(subject),
      cc:      cc
    )
  end

  private

  def custom_subject(subject, existing_user: false)
    trans_key = existing_user ? 'existing_user' : 'new_user'
    subject.presence || I18n.t("invitation.invite_mailer.#{trans_key}.subject")
  end
end
