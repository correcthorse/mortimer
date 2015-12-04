# Be sure to restart your server when you modify this file.

Mortimer::Application.config.session_store :cookie_store,
  :key => '_mortimer_session',
  :secret => "f62576fc728f7500e7e9f61a9b8e1b3154e571d8860cfb05f69c86316f31bc6ceeed78d6e953d59afe313fed93f752f1bb652b02ad84e36fe1106879f670cb4f"

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Mortimer::Application.config.session_store :active_record_store
