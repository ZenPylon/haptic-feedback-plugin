import { WebPlugin } from '@capacitor/core';
import { HapticFeedbackPluginPlugin } from './definitions';

export class HapticFeedbackPluginWeb extends WebPlugin implements HapticFeedbackPluginPlugin {
  constructor() {
    super({
      name: 'HapticFeedbackPlugin',
      platforms: ['web']
    });
  }

  async echo(options: { value: string }): Promise<{value: string}> {
    console.log('ECHO', options);
    return options;
  }
}

const HapticFeedbackPlugin = new HapticFeedbackPluginWeb();

export { HapticFeedbackPlugin };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(HapticFeedbackPlugin);
