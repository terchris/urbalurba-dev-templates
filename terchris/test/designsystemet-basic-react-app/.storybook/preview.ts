import type { Preview } from '@storybook/react';
import '@digdir/designsystemet-css';
import '@digdir/designsystemet-theme';

const preview: Preview = {
  parameters: {
    actions: { argTypesRegex: '^on[A-Z].*' },
    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/,
      },
    },
  },
};

export default preview; 