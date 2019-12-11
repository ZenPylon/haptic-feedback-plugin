declare module '@capacitor/core' {
  interface PluginRegistry {
    HapticFeedback: HapticFeedbackPlugin;
  }
}

export interface HapticFeedbackPlugin {
  start(): Promise<void>;
  stop(): Promise<void>;
}
