import { WebPlugin } from '@capacitor/core';
import { HapticFeedbackPlugin } from './definitions';

export class HapticFeedbackPluginWeb extends WebPlugin
  implements HapticFeedbackPlugin {
  warningMessage = 'Haptics not supported on web';

  constructor() {
    super({
      name: 'HapticFeedbackPlugin',
      platforms: ['web']
    });
  }

  async printNotSupportedWarning() {
    console.warn(this.warningMessage);
  }

  start = this.printNotSupportedWarning;
  stop = this.printNotSupportedWarning;
}

const HapticFeedbackPlugin = new HapticFeedbackPluginWeb();

export { HapticFeedbackPlugin };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(HapticFeedbackPlugin);
