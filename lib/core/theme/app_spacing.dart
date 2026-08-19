/// Formalizes the spacing/radius scale already in de-facto use across the
/// app (16/18/20 padding, 12/14 gaps, 4/6/8 tight gaps, 12-24 radii) so new
/// screens pull from one source instead of re-guessing values.
class AppSpacing {
  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 12.0;
  static const lg  = 16.0;
  static const lg2 = 18.0;
  static const xl  = 20.0;
  static const xl2 = 24.0;
  static const xxl = 32.0;
}

class AppRadius {
  static const sm   = 12.0;
  static const md   = 16.0;
  static const lg   = 20.0;
  static const xl   = 24.0;
  static const pill = 999.0;
}
