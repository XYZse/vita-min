shared_examples "catches exceptions with raven context" do |action|
  context "when error occurs", active_job: true do
    it "sends the intake ticket_id to Sentry" do
      allow(fake_zendesk_intake_service).to receive(action)
        .and_raise("Test Error")
      expect(Raven).to receive(:extra_context)
        .with(hash_including(ticket_id: intake.intake_ticket_id))
      expect { described_class.perform_now(intake.id) }
        .to raise_error(/Test Error/)
    end
  end
end

shared_examples 'a ticket-dependent job' do |zervice|
  context 'when the intake ticket id is missing', active_job: true do
    let(:intake) do
      create :intake, intake_ticket_id: nil
    end

    before do
      allow(zervice).to receive(:new) { double('zervice stand-in').as_null_object }
    end

    it 'raises a MissingTicketError' do
      expect {
        described_class.perform_now(intake.id)
      }.to raise_error(ZendeskIntakeService::MissingTicketError)

      expect(zervice).not_to have_received(:new)
    end
  end
end


