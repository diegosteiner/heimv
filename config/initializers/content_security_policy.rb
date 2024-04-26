# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#   end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
# end
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.style_src :self, :https
  policy.img_src :self, :https, :data

  if Rails.env.development?
    policy.default_src :self, :unsafe_inline
    policy.script_src :self, :unsafe_inline, :unsafe_eval, "http://#{ViteRuby.config.host_with_port}"
    policy.connect_src(*policy.connect_src,
                       'http://localhost:3000',
                       'http://*.localhost:3000',
                       "http://#{ViteRuby.config.host_with_port}",
                       "http://*.#{ViteRuby.config.host_with_port}",
                       "ws://#{ViteRuby.config.host_with_port}",
                       "ws://*.#{ViteRuby.config.host_with_port}")
    policy.style_src(*policy.style_src, :unsafe_inline)
  end

  policy.script_src(*policy.script_src, :blob) if Rails.env.test?
end
