/// Backend base URL for the account/sync features (login, register, whole-farm
/// backup). Everything else in the app is local-first and never calls this.
/// Override at build time with `--dart-define=API_BASE_URL=https://…` for a
/// staging backend; defaults to the production deployment.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://agrivault.bytebridgemw.tech',
);
