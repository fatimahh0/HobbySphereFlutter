enum AppKind { activity, product /* later */ }

class AppConfig {
  final AppKind kind;
  const AppConfig(this.kind);
}
