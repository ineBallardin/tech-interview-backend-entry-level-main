require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  let(:job) { described_class.new }
  
  describe '#perform' do
    context 'when there are carts inactive for more than 3 hours' do
      let!(:active_cart) { create(:cart, last_interaction_at: 1.hour.ago) }
      let!(:inactive_cart) { create(:cart, last_interaction_at: 4.hours.ago) }
      let!(:already_abandoned) { create(:cart, abandoned: true, abandoned_at: 1.day.ago) }
      
      it 'marks only inactive carts as abandoned' do
        expect { job.perform }.to change { 
          inactive_cart.reload.abandoned? 
        }.from(false).to(true)
        
        expect(active_cart.reload.abandoned?).to be false
        expect(already_abandoned.reload.abandoned?).to be true
      end
      
      it 'records the abandonment timestamp' do
        job.perform
        expect(inactive_cart.reload.abandoned_at).to be_within(1.second).of(Time.current)
      end
    end
    
    context 'when there are carts abandoned for more than 7 days' do
      let!(:recent_abandoned) { 
        create(:cart, abandoned: true, abandoned_at: 3.days.ago) 
      }
      let!(:old_abandoned) { 
        create(:cart, abandoned: true, abandoned_at: 8.days.ago) 
      }
      
      it 'removes only carts abandoned for more than 7 days' do
        expect { job.perform }.to change { Cart.count }.by(-1)
        
        expect(Cart.exists?(recent_abandoned.id)).to be true
        expect(Cart.exists?(old_abandoned.id)).to be false
      end
    end
    
    context 'when there are no carts to process' do
      let!(:active_cart) { create(:cart, last_interaction_at: 1.minute.ago) }
      
      it 'runs without errors' do
        expect { job.perform }.not_to raise_error
        expect(active_cart.reload.abandoned?).to be false
      end
    end
  end
end
