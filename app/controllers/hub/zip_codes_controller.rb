module Hub
  class ZipCodesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    authorize_resource :vita_partner, parent: false, only: :create

    def create
      vita_partner = VitaPartner.find(params[:vita_partner_id])
      @form = ZipCodeRoutingForm.new(vita_partner, permitted_params)
      if @form.valid?
        @form.save
      else
        flash.now[:alert] = @form.error_summary
      end
      respond_to do |format|
        format.js
      end
    end

    def destroy
      @zip_code_routing = VitaPartnerZipCode.find_by(id: params[:id])

      unless @zip_code_routing.present?
        flash[:error] = I18n.t("hub.zip_codes.not_found")
        redirect_to request.referrer and return
      end
      @zip_code_routing.destroy!

      respond_to do |format|
        format.js
      end
    end

    def form_class
      ZipCodeRoutingForm
    end

    def permitted_params
      params.require(form_class.form_param).permit(:zip_code)
    end
  end
end