require "rails_helper"

RSpec.describe PublicPagesController do
  render_views

  describe "#home" do
    context "in production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it "does NOT show a banner warning that this is an example site" do
        get :home

        expect(response.body).not_to include("This site is for example purposes only. If you want help with your taxes, go to")
        expect(response.body).not_to include("https://www.getyourrefund.org")
      end

      it "includes GA script in html" do
        get :home

        expect(response.body).to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end

      it "does not link to the first question path for digital intake" do
        get :home

        expect(response.body).not_to include "Get started"
        expect(response.body).not_to include question_path(:id => QuestionNavigation.first)
      end
    end


    context "in demo env" do
      before do
        allow(Rails).to receive(:env).and_return("demo".inquiry)
      end

      it "shows a banner warning that this is an example site" do
        get :home

        expect(response.body).to include("This site is for example purposes only. If you want help with your taxes, go to")
        expect(response.body).to include("https://www.getyourrefund.org")
      end

      it "does not include google analytics" do
        get :home
        expect(response.body).not_to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end
    end

    context "in development env" do
      before do
        allow(Rails).to receive(:env).and_return("development".inquiry)
      end

      it "does not include google analytics" do
        get :home
        expect(response.body).not_to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end
    end

    context "in test env" do
      before do
        allow(Rails).to receive(:env).and_return("test".inquiry)
      end

      it "does not include google analytics" do
        get :home
        expect(response.body).not_to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end
    end
  end

  describe "#diy_home" do
    context "in demo env" do
      before do
        allow(Rails).to receive(:env).and_return("demo".inquiry)
      end

      it "renders the template" do
        get :diy_home
        expect(response).to be_ok
      end
    end

    context "in production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
        allow(I18n).to receive(:locale).and_return(locale)
      end

      context "with English locale" do
        let(:locale) { "en" }

        it "redirects to the English homepage" do
          get :diy_home
          expect(response).to redirect_to("/en")
        end
      end

      context "with Spanish locale" do
        let(:locale) { "es" }

        it "redirects to the English homepage" do
          get :diy_home
          expect(response).to redirect_to("/es")
        end
      end
    end
  end

  describe "#privacy_policy" do
    it "renders successfully" do
      get :privacy_policy
      expect(response).to be_ok
    end
  end
end
