class MouseConfig {
  String primaryButton;
  double mousePointerSpeed;
  bool mouseAcceleration;
  String scrollDirection;
  bool touchpadEnabled;
  bool disableWhileTyping;
  double touchpadPointerSpeed;
  String secondaryClick;
  bool tapToClick;

  MouseConfig({
    this.primaryButton = 'left',
    this.mousePointerSpeed = 0.0,
    this.mouseAcceleration = true,
    this.scrollDirection = 'traditional',
    this.touchpadEnabled = true,
    this.disableWhileTyping = true,
    this.touchpadPointerSpeed = 0.0,
    this.secondaryClick = 'two-finger',
    this.tapToClick = true,
  });

  MouseConfig copyWith({
    String? primaryButton,
    double? mousePointerSpeed,
    bool? mouseAcceleration,
    String? scrollDirection,
    bool? touchpadEnabled,
    bool? disableWhileTyping,
    double? touchpadPointerSpeed,
    String? secondaryClick,
    bool? tapToClick,
  }) {
    return MouseConfig(
      primaryButton: primaryButton ?? this.primaryButton,
      mousePointerSpeed: mousePointerSpeed ?? this.mousePointerSpeed,
      mouseAcceleration: mouseAcceleration ?? this.mouseAcceleration,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      touchpadEnabled: touchpadEnabled ?? this.touchpadEnabled,
      disableWhileTyping: disableWhileTyping ?? this.disableWhileTyping,
      touchpadPointerSpeed: touchpadPointerSpeed ?? this.touchpadPointerSpeed,
      secondaryClick: secondaryClick ?? this.secondaryClick,
      tapToClick: tapToClick ?? this.tapToClick,
    );
  }
}
