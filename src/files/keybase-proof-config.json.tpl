{
  "version": "${version}",
  "domain": "${identity_domain}",
  "display_name": "${display_name}",
  "username": {
    "re": "^[a-zA-Z0-9\\.]{2,20}$",
    "min": 2,
    "max": 30
  },
  "brand_color": "${brand_color}",
  "logo": {
    "svg_black": "https://${keybase_fqdn}/static/small-black-logo.svg",
    "svg_full": "https://${keybase_fqdn}/static/full-color.logo.svg"
  },
  "description": "${description}",
  "prefill_url": "https://${keybase_fqdn}/new-profile-proof?kb_username=%%{kb_username}&username=%%{username}&token=%%{sig_hash}&kb_ua=%%{kb_ua}",
  "profile_url": "https://${keybase_fqdn}/profile/%%{username}",
  "check_url": "https://${keybase_fqdn}/keybase-proofs.json?username=%%{username}",
  "check_path": ["signatures"],
  "avatar_path": ["avatar"],
  "contact": ["admin@${identity_domain}"]
}