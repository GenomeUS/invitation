require 'spec_helper'

describe InviteMailer do
  def get_message_part(mail, content_type)
    mail.body.parts.find { |p| p.content_type.match content_type }.body.raw_source
  end

  shared_examples_for 'multipart email' do
    it 'generates a multipart message (plain text and html)' do
      expect(mail.body.parts.length).to eq 2
      expect(mail.body.parts.collect(&:content_type)).to eq ['text/plain; charset=UTF-8', 'text/html; charset=UTF-8']
    end
  end

  shared_examples_for 'multipart email with bodies' do
    context 'multipart email bodies' do
      describe 'text version' do
        let(:part) { get_message_part(mail, /plain/) }
        it 'has invite content' do
          expect(part).to match(/#{invite.sender.email} has invited you to/)
        end
      end

      describe 'html version' do
        let(:part) { get_message_part(mail, /html/) }
        it 'has invite content' do
          expect(part).to match(/#{invite.sender.email} has invited you to/)
        end
      end
    end
  end

  shared_examples_for 'email subject' do |extra_text = ''|
    it "renders the subject #{extra_text}" do
      expect(mail.subject).to eq expected_subject
    end
  end

  shared_examples_for 'email body' do |extra_text = ''|
    it "renders the email body #{extra_text}" do
      expect(mail.body.encoded).to match(expected_message)
    end
  end

  describe '#existing_user_invite' do
    let(:invite) { create(:invite, :recipient_is_existing_user) }
    let(:mail)   { InviteMailer.existing_user(invite) }
    let(:expected_subject) { 'Invitation instructions' }

    it_behaves_like 'multipart email'
    it_behaves_like 'multipart email with bodies'

    context 'when no custom subject is provided' do
      include_examples 'email subject'
    end

    context 'when custom subject is provided' do
      let(:mail)             { InviteMailer.new_user(invite, subject: expected_subject) }
      let(:expected_subject) { 'I can write custom subject' }

      include_examples 'email subject', 'custom'
    end

    it 'renders the recipient email' do
      expect(mail.to).to eq([invite.recipient.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([Invitation.configuration.mailer_sender])
    end
  end

  describe '#new_user_invite' do
    before do
      allow(Invitation.configuration).to receive(:user_registration_url).and_return(lambda do |_params|
        'http://example.org/user_reg_link'
      end)
    end
    let(:invite)           { create(:invite, :recipient_is_new_user) }
    let(:mail)             { InviteMailer.new_user(invite) }
    let(:expected_subject) { 'Invitation instructions' }

    it_behaves_like 'multipart email'
    it_behaves_like 'multipart email with bodies'

    context 'when no custom subject is provided' do
      include_examples 'email subject'
    end

    context 'when custom subject is provided' do
      let(:mail)             { InviteMailer.new_user(invite, subject: expected_subject) }
      let(:expected_subject) { 'I can write custom subject' }

      include_examples 'email subject', 'custom'
    end

    context 'when custom message is provided' do
      let(:mail) do
        InviteMailer.new_user(invite,
                              subject: expected_subject,
                              message: expected_message)
      end
      let(:expected_message) { 'I can write custom message' }

      it 'adds custom message to email body' do
        expect(mail.body.encoded).to match(expected_message)
      end
    end

    it 'renders the recipient email' do
      expect(mail.to).to eq([invite.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([Invitation.configuration.mailer_sender])
    end
  end
end
