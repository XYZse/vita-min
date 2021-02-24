require "rails_helper"

RSpec.describe ClientSortable, type: :controller do
  # this is a concern spec, so it only needs some portions of a controller
  # - it needs current_user for one particular method
  # - it needs params
  # - it assumes that @clients is already set.
  let(:clients_query_double){ double }
  let(:intakes_query_double){ double }

  controller(ApplicationController) do
    include ClientSortable
  end

  before do
    allow(subject).to receive(:params).and_return params
    subject.instance_variable_set(:@clients, clients_query_double)
    allow(clients_query_double).to receive(:after_consent).and_return clients_query_double
    allow(clients_query_double).to receive(:delegated_order).and_return clients_query_double
    allow(clients_query_double).to receive(:where).and_return clients_query_double
    allow(clients_query_double).to receive(:not).and_return clients_query_double
    allow(Intake).to receive(:search).and_return intakes_query_double
  end

  describe "#filtered_and_sorted_clients" do
    context "with a 'search' param" do
      let(:params) do
        { search: "que" }
      end

      it "creates a search query for intakes and queries clients for those intakes" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(Intake).to have_received(:search).with "que"
        expect(clients_query_double).to have_received(:where).with(intake: intakes_query_double)
      end
    end

    context "with a 'search' param and additional filters" do
      let(:params) do
        {
          search: "query",
          status: "intake_ready"
        }
      end

      it "creates a query for the search and scopes by other provided queries" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with({ tax_returns: { status: params[:status].to_sym } })
        expect(clients_query_double).to have_received(:where).with(intake: intakes_query_double)
      end
    end

    context "with a vita partner id" do
      let(:vita_partner) { create :vita_partner }
      let(:params) {
        {
          vita_partner_id: vita_partner.id
        }
      }


      it "creates a query for the search and scopes to vita partner" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with('vita_partners.id = ? OR vita_partners.parent_organization_id = ?', vita_partner.id, vita_partner.id)
      end
    end

    context "with a selected assigned user id" do
      let(:user) { create :user }
      let(:params) {
        {
            assigned_user_id: user.id
        }
      }

      it "creates a query that includes the call to limit to assigned user" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with({ tax_returns: { assigned_user: [user.id] } })
      end
    end

    context "with a selected assigned user id AND assigned to me selected" do
      let(:user) { create :user }
      let(:current_user) { create :user }
      let(:params) {
        {
            assigned_user_id: user.id,
            assigned_to_me: true
        }
      }
      before do
        allow(subject).to receive(:current_user).and_return(current_user)
      end

      it "creates a query that includes a call to limit to assigned to current user AND some other user" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with({ tax_returns: { assigned_user: [current_user.id, user.id] } })
      end
    end
    
    context "with a clear param" do
      let(:params) do
        {
            clear: true,
            search: "query",
            status: "intake_in_progress",
            year: "2019",
            needs_response: true,
            assigned_to_me: true,
            unassigned: true,
            vita_partner_id: 1,
            assigned_user_id: 1
        }
      end

      it "clears all of the existing params" do
        subject.filtered_and_sorted_clients
        expect(assigns(:filters).values.compact).to be_empty
      end
    end

    context "searching for phone numbers" do
      before { subject.filtered_and_sorted_clients }

      context "with a simple phone number digit-only search" do
        let(:params) { { search: "4155551212" } }

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "+14155551212"
        end
      end

      context "with a phone number in a common local format" do
        let(:params) { { search: "(415) 555-1212" } }

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "+14155551212"
        end
      end

      context "with a phone number in an unofficial but commonly entered format" do
        let(:params) { { search: "415.555.1212" } }

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "+14155551212"
        end
      end

      context "with the last seven digits of a phone number" do
        let(:params) { { search: "555-1212" } }

        it "passes the number to search with no normalization" do
          expect(Intake).to have_received(:search).with "555-1212"
        end
      end

      context "with a phone number and another field in the search query" do
        let(:params) do
          { search: "colleen 415555(1212)" }
        end

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "colleen +14155551212"
        end
      end
    end
  end

  describe "#has_search_and_sort_params?" do
    context "when containing a sort or search param" do
      context "search" do
        let(:params) { { search: "que" } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "status" do
        let(:params) { { search: "prep_ready_for_prep" } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "unassigned" do
        let(:params) { { unassigned: true } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "assigned_to_me" do
        let(:params) { { assigned_to_me: true } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "needs_response" do
        let(:params) { { needs_response: true } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "year" do
        let(:params) { { year: 2019 } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "vita_partner_id" do
        let(:params) { { vita_partner_id: 1 } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end
    end

    context "without a search or sort param" do
      let(:params) { { something: 'hello' } }
      it "returns false" do
        expect(subject.has_search_and_sort_params?).to eq false
      end
    end
  end
end
