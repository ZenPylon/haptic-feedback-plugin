declare module '@capacitor/core' {
  interface PluginRegistry {
    HapticFeedback: HapticFeedbackPlugin;
  }
}

export interface HapticFeedbackPlugin {
  startEngine(): Promise<void>;
  stopEngine(): Promise<void>;
  makeAdvancedPlayer(): Promise<void>;
  startPlayer(): Promise<void>;
  stopPlayer(): Promise<void>;
}
