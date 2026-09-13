{ fetchurl }:

# Merged GeoIP database (GeoLite2 + DB-IP + IP2Location) that invisible-core
# uses to resolve session locale and timezone from the egress IP. Point
# invisible-core at it with STEALTHFOX_GEOIP_MMDB, otherwise it downloads the
# latest build at runtime.
fetchurl {
  name = "geoip-aio-all.mmdb";
  url = "https://github.com/daijro/geoip-all-in-one/releases/download/2026.09.09/geoip-aio-all.mmdb";
  hash = "sha256-OFEEnNP4ltCn5nN6FN7i82oU3LdV4C4u6cP2KmOH17o=";
}
