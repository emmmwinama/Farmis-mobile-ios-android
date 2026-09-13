/// Base URL for Ulimi's mobile API (`/api/mobile/...`) — see
/// `docs/MOBILE-API.md` in the Ulimi-app repo for the full contract.
/// Override at build time with `--dart-define=API_BASE_URL=https://…` for a
/// staging backend; defaults to the production deployment.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://agrivault.bytebridgemw.tech',
);
