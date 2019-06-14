# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: "_nsl_editor_session_#{Rails.configuration.try('session_key_tag')}", expire_after: 3.hours
