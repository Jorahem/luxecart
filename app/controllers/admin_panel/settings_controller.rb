module AdminPanel
  class SettingsController < AdminPanel::BaseController
    def show
      load_settings
    end

    def update
      # Simple, migration-free approach: store admin UI settings in session.
      # If you want settings persisted in DB, tell me and I'll add Setting model + migration.
      session[:admin_settings] ||= {}
      session[:admin_settings]["store_name"] = params.dig(:settings, :store_name)
      session[:admin_settings]["support_email"] = params.dig(:settings, :support_email)

      redirect_to admin_settings_path, notice: "Settings updated."
    end

    private

    def load_settings
      session[:admin_settings] ||= {}

      @settings = {
        store_name: session[:admin_settings]["store_name"].presence || "LuxeCart",
        support_email: session[:admin_settings]["support_email"].presence || "support@example.com",
        stripe_public_key_present: ENV["STRIPE_PUBLISHABLE_KEY"].present?,
        stripe_secret_key_present: ENV["STRIPE_SECRET_KEY"].present?
      }
    end
  end
end