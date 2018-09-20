# Send invitations to new and existing users.
class InviteMailer < ActionMailer::Base
  def existing_user(invite, opts = {})
    @invite = invite
    mail(
      from: Invitation.configuration.mailer_sender,
      to: @invite.email,
      subject: custom_subject(opts[:subject], existing_user: true)
    )
  end

  def new_user(invite, opts = {})
    @invite = invite
    @user_registration_url = Invitation.configuration.user_registration_url.call(invite_token: @invite.token)
    mail(
      from: Invitation.configuration.mailer_sender,
      to: @invite.email,
      subject: custom_subject(opts[:subject])
    )
  end

  private

  def custom_subject(subject, existing_user: false)
    trans_key = existing_user ? 'existing_user' : 'new_user'
    subject.presence || I18n.t("invitation.invite_mailer.#{trans_key}.subject")
  end
end
