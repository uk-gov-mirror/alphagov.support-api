require 'rails_helper'

RSpec.describe AnonymousFeedback::ExportRequestsController, type: :controller do
  describe "#create" do
    context "posted with valid parameters" do
      before do
        expect(GenerateFeedbackCsvWorker).to receive(:perform_async).once.with(instance_of(Fixnum))
        post :create, export_request: {
          from: "2015-05-01", to: "2015-06-01",
          path_prefix: "/", notification_email: "foo@example.com"
        }
      end

      subject { response }

      it { is_expected.to be_accepted }
    end

    context "posted with invalid parameters" do
      before do
        expect(GenerateFeedbackCsvWorker).to receive(:perform_async).never
        post :create, export_request: {
          from: "2015-05-01", to: "2015-06-01",
          path_prefix: "/"
        }
      end

      subject { response }

      it { is_expected.to be_unprocessable }
    end
  end

  describe "#show" do
    before { get :show, id: id }

    subject { response }

    context "requesting a non-existant export request" do
      let(:id) { 1 }

      it { is_expected.to be_not_found }
    end

    context "requesting a pending export request" do
      let(:export_request) { create(:feedback_export_request) }
      let(:id) { export_request.id }

      it { is_expected.to be_success }

      it "returns the URL" do
        expect(JSON.parse(response.body)["filename"]).to eq export_request.filename
      end

      it "returns a status of not ready" do
        expect(JSON.parse(response.body)["ready"]).to be false
      end

    end

    context "requesting a processed export request" do
      let(:export_request) { create(:feedback_export_request, generated_at: Time.now) }
      let(:id) { export_request.id }

      it { is_expected.to be_success }

      it "returns the URL" do
        expect(JSON.parse(response.body)["filename"]).to eq export_request.filename
      end

      it "returns a status of ready" do
        expect(JSON.parse(response.body)["ready"]).to be true
      end
    end
  end
end