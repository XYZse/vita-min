require "rails_helper"

RSpec.feature "Visit home page" do
  scenario "has most critical content" do
    visit "/"
    expect(page).to have_text "Free tax filing, real human support."
    expect(page).to have_text "Sign up for next tax season now. We’ll notify you as soon as our service is back up in January!"
    expect(page).to have_link "Sign Up"
    click_on "Sign Up"
    expect(page).to have_text "sign up here"
  end

  scenario "it has the correct SEO link tags in English" do
    visit "/en?source=test"
    # We are currently viewing the English homepage so the canonical URL is the English version.
    # Params should be ignored since the content is always the same.
    expect(page).to have_css 'link[rel="canonical"][href="http://www.example.com/en"]', :visible => false
    # The x-default language alternate is our default locale English
    expect(page).to have_css 'link[rel="alternate"][hreflang="x-default"][href="http://www.example.com/en"]', :visible => false
    expect(page).to have_css 'link[rel="alternate"][hreflang="en"][href="http://www.example.com/en"]', :visible => false
    expect(page).to have_css 'link[rel="alternate"][hreflang="es"][href="http://www.example.com/es"]', :visible => false
  end

  scenario "it has the correct SEO link tags in Spanish" do
    visit "/es?source=test"
    # We are currently viewing the Spanish homepage so the canonical URL is the Spanish version, with locale included
    # Params should be ignored since the content is always the same.
    expect(page).to have_css 'link[rel="canonical"][href="http://www.example.com/es"]', :visible => false
    # The x-default language alternate is our default locale English
    expect(page).to have_css 'link[rel="alternate"][hreflang="x-default"][href="http://www.example.com/en"]', :visible => false
    expect(page).to have_css 'link[rel="alternate"][hreflang="en"][href="http://www.example.com/en"]', :visible => false
    expect(page).to have_css 'link[rel="alternate"][hreflang="es"][href="http://www.example.com/es"]', :visible => false
  end

  context "in non-production environments" do
    before do
      allow(Rails.env).to receive(:production?).and_return(false)
    end

    scenario "it shows a sign in link" do
      visit "/"
      click_on "Volunteer sign in"
      expect(page).to have_text "Sign in"
    end
  end
end
