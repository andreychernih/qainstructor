RSpec.describe UserRegistered do
  let(:user) { create(:user) }

  describe '#perform' do
    it 'sends confirmation instructions' do
      allow(User).to receive(:find).with(user.id).and_return(user)
      expect(user).to receive(:send_confirmation_instructions)
      described_class.perform_async(user.id)
    end

    context 'when TRIAL50 coupon exists' do
      it 'sends promotional email' do
        course = create(:course)
        create(:coupon, course: course, code: 'TRIAL50')
        expect(PromotionsMailer).to receive(:trial_coupon_email).and_call_original
        described_class.perform_async(user.id)
      end
    end

    context 'when TRIAL50 coupon does not exist' do
      it 'does not send promotional email' do
        expect(PromotionsMailer).not_to receive(:trial_coupon_email)
        described_class.perform_async(user.id)
      end
    end
  end
end