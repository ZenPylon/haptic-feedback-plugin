declare module "@capacitor/core" {
  interface PluginRegistry {
    HapticFeedbackPlugin: HapticFeedbackPluginPlugin;
  }
}

export interface HapticFeedbackPluginPlugin {
  echo(options: { value: string }): Promise<{value: string}>;
}
