require 'rails_helper'

RSpec.describe UserService, type: :service do
  describe 'create' do
    let(:service) { described_class.new(parameters) }

    context 'with invalid parameters' do
      let(:parameters) { attributes_for(:user).merge(name: '') }

      it 'does not create a new user' do
        expect { service.create }.not_to change(User, :count)
      end

      it 'returns false' do
        service.create

        expect(service).not_to be_success
      end

      it 'returns the errors' do
        service.create

        expect(service.errors).not_to be_empty
      end
    end

    context 'with valid parameters' do
      let(:parameters) { attributes_for(:user) }

      it 'creates a new user' do
        expect { service.create }.to change(User, :count).by(1)
      end

      it 'returns the created user' do
        service.create

        expect(service.record).to eq(User.last)
      end

      it 'returns true' do
        service.create

        expect(service).to be_success
      end

      it 'creates the record with the correct data' do
        service.create

        record = service.record

        expect(record).not_to be_nil

        expect(User.genders[record.gender]).to eq(parameters[:gender])
        expect(record.name).to eq(parameters[:name])
        expect(record.email).to eq(parameters[:email])
      end
    end
  end

  describe 'update' do
    let(:service) { described_class.new(parameters) }

    let!(:user) { create(:user) }
    let(:id) { user.id }

    context 'with invalid parameters' do
      let(:parameters) { attributes_for(:user).merge(name: '') }

      it 'does not update the user' do
        expect do
          service.update(id)
        end.not_to change(User, :count)
      end

      it 'returns false' do
        service.update(id)

        expect(service).not_to be_success
      end

      it 'returns no record' do
        service.update(id)

        expect(service.record).to be_nil
      end

      it 'returns the errors' do
        service.update(id)

        expect(service.errors).not_to be_empty
      end
    end

    context 'with valid parameters' do
      let(:parameters) { attributes_for(:user) }

      it 'updates the user' do
        expect { service.update(id) }.to(change { user.reload.updated_at })
      end

      it 'returns true' do
        service.update(id)

        expect(service).to be_success
      end

      it 'returns the updated record' do
        service.update(id)

        expect(service.record).to eq(user.reload)
      end

      it 'updates the record with the correct data' do
        service.update(id)

        record = service.record

        expect(record).not_to be_nil

        expect(User.genders[record.gender]).to eq(parameters[:gender])
        expect(record.name).to eq(parameters[:name])
        expect(record.email).to eq(parameters[:email])
      end

      it 'returns no errors' do
        service.update(id)

        expect(service.errors).to be_empty
      end
    end
  end

  describe 'destroy' do
    let(:service) { described_class.new }

    let!(:user) { create(:user) }
    let(:id) { user.id }

    context 'with invalid parameters' do
      let(:user_double) { instance_double(User, destroy: false, errors: double(:errors, full_messages: ['lorem ipsum'])) }

      before do
        allow(User).to receive(:find).and_return(user_double)
      end

      it 'does not destroy a user' do
        expect do
          service.destroy(id)
        end.not_to change(User, :count)
      end

      it 'returns false' do
        service.destroy(id)

        expect(service).not_to be_success
      end

      it 'returns the errors' do
        service.destroy(id)

        expect(service.errors).not_to be_empty
      end
    end

    context 'with valid parameters' do
      it 'destroys the user' do
        expect do
          service.destroy(id)
        end.to change(User, :count).by(-1)
      end

      it 'returns true' do
        service.destroy(id)

        expect(service).to be_success
      end
    end
  end

  describe 'import' do
    let(:service) { described_class.new }

    let(:params) { { format: 'json', results: '4', inc: 'gender,name,email,picture', nat: 'br', seed: 'giga' } }

    context 'with error' do
      context 'with api' do
        before do
          allow(HTTParty).to receive(:get).and_return({})
          allow(Rails.logger).to receive(:error)
        end

        it 'log error' do
          service.import(params)

          expect(Rails.logger).to have_received(:error).at_least(:once)
        end
      end

      context 'with saving' do
        before do
          allow_any_instance_of(User).to receive(:save).and_return(false)
        end

        it 'does not create any user' do
          expect do
            service.import(params)
          end.to change(User, :count).by(0)
        end
      end
    end

    context 'with success' do
      it 'import four users' do
        expect do
          service.import(params)
        end.to change(User, :count).by(4)
      end
    end
  end
end
